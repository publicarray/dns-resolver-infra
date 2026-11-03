SERVER_IP=${SERVER_IP:-45.76.113.31}
TLS_HOST=${TLS_HOST:-dot.seby.io}
DOH_URL=${DOH_URL:-https://doh-1.seby.io/dns-query}

dns_query() {
    local name=$1 type=${2:-A} label t
    printf '\253\315\001\040\000\001\000\000\000\000\000\000'
    local IFS=.
    for label in $name; do
        [ -n "$label" ] && printf "\\$(printf '%03o' "${#label}")%s" "$label"
    done
    case $type in
        A) t='\000\001' ;;
        NS) t='\000\002' ;;
        SOA) t='\000\006' ;;
        AAAA) t='\000\034' ;;
        *) echo "unsupported type $type" >&2; return 1 ;;
    esac
    printf "\\000${t}\\000\\001"
}

with_length() {
    local f n
    f=$(mktemp)
    cat > "$f"
    n=$(wc -c < "$f")
    printf "\\$(printf '%03o' $((n / 256)))\\$(printf '%03o' $((n % 256)))"
    cat "$f"
    rm -f "$f"
}

dns_summary() {
    local b rcode
    read -r -a b < <(od -An -tu1 -N8 -v | tr -s ' \n' ' ')
    [ "${#b[@]}" -ge 8 ] || { echo "no response"; return 1; }
    case $((b[3] & 15)) in
        0) rcode=NOERROR ;; 1) rcode=FORMERR ;; 2) rcode=SERVFAIL ;;
        3) rcode=NXDOMAIN ;; 4) rcode=NOTIMP ;; 5) rcode=REFUSED ;;
        *) rcode="RCODE$((b[3] & 15))" ;;
    esac
    printf '%s' "$rcode"
    (( b[3] & 32 )) && printf ' ad'
    printf ' answers=%d\n' $((b[6] * 256 + b[7]))
}

stream_exchange() {
    local transport=$1 extra=()
    shift
    [ "$transport" = quic ] && extra=(-quic -alpn doq)
    (dns_query "$@" | with_length; sleep 1) |
        timeout 10 openssl s_client "${extra[@]}" -quiet -no_ign_eof \
            -connect "$SERVER_IP:853" -servername "$TLS_HOST" -verify_return_error 2>/dev/null |
        tail -c +3
}

dot_lookup() {
    stream_exchange tls "$@" | dns_summary
}

doq_lookup() {
    stream_exchange quic "$@" | dns_summary
}

doh_lookup() {
    dns_query "$@" |
        curl -s -f -m 10 -H 'content-type: application/dns-message' --data-binary @- "$DOH_URL" |
        dns_summary
}
