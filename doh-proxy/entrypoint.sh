#!/bin/sh
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

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"1.1.1.1"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
while getopts "h?d" opt; do
    case "$opt" in
        h|\?) echo "-d  domain lookup for service discovery"; exit 0;;
        d) UNBOUND_SERVICE_HOST="$(waitOrFail getServiceIP unbound)"
           [ -z "$UNBOUND_SERVICE_HOST" ] || exit 1
        ;;
    esac
done
shift $((OPTIND-1))
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"

if [ $# -eq 0 ]; then
    echo "doh-proxy - resolver: $RESOLVER"
    exec /usr/local/bin/doh-proxy --server-address "${RESOLVER}" --listen-address 0.0.0.0:3000
fi

[ "$1" = '--' ] && shift

exec /usr/local/bin/doh-proxy "$@"
