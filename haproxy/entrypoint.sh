#!/bin/sh
set -e

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"1.1.1.1"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"

DOH_PROXY_SERVICE_HOST=${DOH_PROXY_SERVICE_HOST-"127.0.0.1"}
DOH_PROXY_SERVICE_PORT=${DOH_PROXY_SERVICE_PORT-"3000"}
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
