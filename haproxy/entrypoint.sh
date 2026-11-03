#!/bin/sh
set -e
set -x

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"1.1.1.1"}
# unbound's PROXYv2 (proxy-protocol-port) listener for the DoT backend
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"5353"}
DOH_PROXY_SERVICE_HOST=${DOH_PROXY_SERVICE_HOST-"127.0.0.1"}
DOH_PROXY_SERVICE_PORT=${DOH_PROXY_SERVICE_PORT-"3000"}

export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"
export DOH_SERVER="$DOH_PROXY_SERVICE_HOST:$DOH_PROXY_SERVICE_PORT"

STOP_TIMEOUT=${STOP_TIMEOUT-30}

set -f
: > /etc/haproxy/redirects.map
for pair in ${REDIRECTS-}; do
    case "$pair" in
        ?*=?*) printf '%s %s\n' "$(echo "${pair%%=*}" | tr 'A-Z' 'a-z')" "${pair#*=}" >> /etc/haproxy/redirects.map ;;
        *) echo "==> ignoring invalid REDIRECTS entry: $pair" >&2 ;;
    esac
done
set +f

sed -i -e "s/^\([[:space:]]*\)server doh-proxy [^ ]*/\1server doh-proxy ${DOH_SERVER}/" \
    -e "s/^\([[:space:]]*\)server dns [^ ]*/\1server dns ${RESOLVER}/" \
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
