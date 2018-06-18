#!/bin/sh

# -N provider-name -E external-ip-address:port

set -e

getServiceIP () {
    nslookup "$1" 2>/dev/null | grep -oE '(([0-9]{1,3})\.){3}(1?[0-9]{1,3})'
}

waitOrFail () {
    maxTries=9
    i=0
    while [ $i -lt $maxTries ]; do
        outStr="$($@)"
        if [ $? -eq 0 ];then
            echo "$outStr"
            return
        fi
        i=$((i+1))
        sleep 10
    done
    echo "Too many failed attempts" >&2
    exit 1
}

KEYS_DIR="/opt/dnscrypt/etc/keys"
UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"1.1.1.1"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
if [ -n "$(waitOrFail getServiceIP unbound)" ]; then
    UNBOUND_SERVICE_HOST=$(getServiceIP unbound)
fi
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"

init() {
    if [ "$(is_initialized)" = yes ]; then
        start
        exit $?
    fi
    while getopts "h?N:E:" opt; do
        case "$opt" in
            h|\?) usage ;;
            N) provider_name=$(echo "$OPTARG" | sed -e 's/^[ \t]*//' | tr "[:upper:]" "[:lower:]") ;;
            E) ext_address=$(echo "$OPTARG" | sed -e 's/^[ \t]*//' | tr "[:upper:]" "[:lower:]") ;;
        esac
    done
    [ -z "$provider_name" ] && usage
    case "$provider_name" in
        .*) usage ;;
        2.dnscrypt-cert.*) ;;
        *) provider_name="2.dnscrypt-cert.${provider_name}"
    esac

    [ -z "$ext_address" ] && usage
    case "$ext_address" in
        .*) usage ;;
        0.*) echo "Do not use 0.0.0.0, use an actual external IP address" >&2 ; exit 1 ;;
    esac

    echo "Provider name: [$provider_name]"
    mkdir -p "$KEYS_DIR" "$KEYS_DIR/short-term" /opt/dnscrypt/empty
    cd "$KEYS_DIR"
    /usr/local/sbin/dnscrypt-wrapper \
        --gen-provider-keypair --nolog --dnssec --nofilter \
        --provider-name="$provider_name" --ext-address="$ext_address" | \
        tee "${KEYS_DIR}/provider-info.txt"
    chmod 640 "${KEYS_DIR}/secret.key"
    chmod 644 "${KEYS_DIR}/public.key"
    chown root:_dnscrypt-signer "${KEYS_DIR}/public.key" "${KEYS_DIR}/secret.key"
    echo "$provider_name" > "${KEYS_DIR}/provider_name"
    chmod 644 "${KEYS_DIR}/provider_name"
    hexdump -ve '1/1 "%.2x"' < "${KEYS_DIR}/public.key" > "${KEYS_DIR}/public.key.txt"
    chmod 644 "${KEYS_DIR}/public.key.txt"
    echo
    echo -----------------------------------------------------------------------
    echo
    echo "Congratulations! The container has been properly initialized."
    echo "Take a look up above at the way dnscrypt-proxy has to be configured in order"
    echo "to connect to your resolver. Then, start the container with the default command."
}

provider_info() {
    ensure_initialized
    echo "Provider name:"
    cat "${KEYS_DIR}/provider_name"
    echo
    echo "Provider public key:"
    cat "${KEYS_DIR}/public.key.txt"
    echo
}

is_initialized() {
    if [ ! -f "${KEYS_DIR}/public.key" ] && [ ! -f "${KEYS_DIR}/secret.key" ] && [ ! -f "${KEYS_DIR}/provider_name" ]; then
        echo no
    else
        echo yes
    fi
}

ensure_initialized() {
    if [ "$(is_initialized)" = no ]; then
        echo "Please provide an initial configuration (init -N <provider_name> -E <external IP>)" >&2
        exit 1
    fi
}

start() {
    ensure_initialized
    echo "Starting DNSCrypt service for provider: "
    cat "${KEYS_DIR}/provider_name"
    exec /sbin/runsvdir -P /etc/service
}

usage() {
    cat << EOT
Commands
========

* init -N <provider_name> -E <external ip>:<port>
initialize the container for a server accessible at ip <external ip> on port
<port>, for a provider named <provider_name>. This is required only once.

* start (default command): start the resolver and the dnscrypt server proxy.
Ports 443/udp and 443/tcp have to be publicly exposed.

* provider-info: prints the provider name and provider public key.

This container has a single volume that you might want to securely keep a
backup of: /opt/dnscrypt/etc/keys
EOT
    exit 1
}

case "$1" in
    start) start ;;
    init) shift; init "$@" ;;
    provider-info) provider_info ;;
    *) usage ;;
esac
