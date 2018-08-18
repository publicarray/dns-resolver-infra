#!/bin/sh
set -e

getServiceIP () {
    nslookup "$1" 2>/dev/null | grep -oE '(([0-9]{1,3})\.){3}(1?[0-9]{1,3})'
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
DOH_PROXY_SERVICE_HOST=${DOH_PROXY_SERVICE_HOST-"127.0.0.1"}
DOH_PROXY_SERVICE_PORT=${DOH_PROXY_SERVICE_PORT-"3000"}
while getopts "h?d" opt; do
    case "$opt" in
        h|\?)
            echo "-d  domain lookup for service discovery";
            echo "-r  uncomment lines in haproxy.conf with the word 'redirect' in them";
            exit 0
        ;;
        d)
            UNBOUND_SERVICE_HOST="$(waitOrFail getServiceIP unbound)"
            DOH_PROXY_SERVICE_HOST="$(waitOrFail getServiceIP doh-proxy)"
        ;;
        r)
            sed -i '/^#.* redirect /s/^#//' /etc/haproxy.conf
        ;;
    esac
done
shift $((OPTIND-1))
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"
export DOH_SERVER="$DOH_PROXY_SERVICE_HOST:$DOH_PROXY_SERVICE_PORT"

sed -i -e "s/server doh-proxy .*/server doh-proxy ${DOH_SERVER}/" \
    -e "s/server dns .*/server dns ${RESOLVER}/" \
    /etc/haproxy.conf

if [ $# -eq 0 ]; then
    exec /usr/local/sbin/haproxy -V -f /etc/haproxy.conf # [-de] single threaded - poll is likely faster then epoll
fi
# /usr/local/sbin/haproxy -D -V -f /etc/haproxy.conf

[ "$1" = '--' ] && shift
exec "$@"
