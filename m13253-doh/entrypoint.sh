#!/bin/sh
set -e

getServiceIP () {
    nslookup "$1" 2>/dev/null | tail -n 4 | grep -oE '(([0-9]{1,3})\.){3}(1?[0-9]{1,3})'
}

waitOrFail () {
    maxTries=24
    i=0
    while [ $i -lt $maxTries ]; do
        outStr="$($@)"
        if [ $? -eq 0 ];then
            echo "$outStr"
            return
        fi
        i=$((i+1))
        echo "==> waiting for a dependent service $i/$maxTries" >&2
        sleep 5
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
        ;;
    esac
done
shift $((OPTIND-1))
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"
echo "==> Configuring doh"
sed \
    -e "s/\"udp:127.0.0.1:53\"/\"udp:${RESOLVER}\"/g" \
    -i  "/etc/dns-over-https/doh-server.conf"

if [ $# -eq 0 ]; then
    echo "doh - resolver: $RESOLVER"
    exec /usr/local/bin/doh-server -conf /etc/dns-over-https/doh-server.conf
fi

[ "$1" = '--' ] && shift

exec /usr/local/bin/doh-server "$@"
