#!/bin/sh
set -e
set -x

getServiceIP () {
    for arg; do
        if ip="$(dig +short "$arg" | grep -m1 .)"; then
            echo "$ip"
            return 0
        fi
    done
    return 1
}

waitOrFail () {
    maxTries=24
    i=0
    while [ $i -lt $maxTries ]; do
        if outStr="$("$@")"; then
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
# unbound's PROXYv2 (proxy-protocol-port) listener for the DoT backend
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"5353"}
DOH_PROXY_SERVICE_HOST=${DOH_PROXY_SERVICE_HOST-"127.0.0.1"}
DOH_PROXY_SERVICE_PORT=${DOH_PROXY_SERVICE_PORT-"3000"}

if [ ! -f /opt/ssl/dhparam.pem ]; then
    openssl dhparam -out /opt/ssl/dhparam.pem 4096
fi

while getopts "h?dr" opt; do
    case "$opt" in
        h|\?)
            echo "-d  domain lookup for service discovery";
            echo "-r  uncomment lines in haproxy.conf with the word 'redirect' in them";
            exit 0
        ;;
        d)
            UNBOUND_SERVICE_HOST="$(waitOrFail getServiceIP unbound)"
            DOH_PROXY_SERVICE_HOST="$(waitOrFail getServiceIP doh-proxy m13253-doh)"
        ;;
        r)
            sed -i '/^#.* redirect /s/^#//' /etc/haproxy.conf
        ;;
    esac
done
shift $((OPTIND-1))
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"
export DOH_SERVER="$DOH_PROXY_SERVICE_HOST:$DOH_PROXY_SERVICE_PORT"

STOP_TIMEOUT=${STOP_TIMEOUT-30}

sed -i -e "s/server doh-proxy .*/server doh-proxy ${DOH_SERVER}/" \
    -e "s|server dns .*|server dns ${RESOLVER} send-proxy-v2 maxconn 256|" \
    -e "s/hard-stop-after .*/hard-stop-after ${STOP_TIMEOUT}s/" \
    /etc/haproxy.conf

/usr/sbin/runsvdir -P /etc/service &
runsvdir_pid=$!

stopCmd () {
    status=0
    if [ "$cmd" != "$runsvdir_pid" ]; then
        kill "$cmd" 2>/dev/null || true
        wait "$cmd"
        status=$?
    fi
    kill "$runsvdir_pid" 2>/dev/null || true
}

softStop () {
    sv once /etc/service/haproxy || true
    sv 1 /etc/service/haproxy || true
    n=0
    while [ -n "$(pidof haproxy)" ] && [ "$n" -lt "$STOP_TIMEOUT" ]; do
        sleep 1
        n=$((n+1))
    done
    sv force-stop /etc/service/haproxy || true
    stopCmd
    exit 0
}

hardStop () {
    sv force-stop /etc/service/haproxy || true
    stopCmd
    exit "$status"
}

if [ $# -gt 0 ]; then
    [ "$1" = '--' ] && shift
    "$@" <&0 &
    cmd=$!
else
    cmd=$runsvdir_pid
fi

set +e
trap softStop USR1
trap hardStop TERM INT

wait "$cmd"
exit $?
