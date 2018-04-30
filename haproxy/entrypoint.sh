#!/bin/sh
set -e

HAPROXY_SERVICE_HOST=${HAPROXY_SERVICE_HOST-"127.0.0.1"}
HAPROXY_SERVICE_PORT=${HAPROXY_SERVICE_PORT-"3000"}
export DOH_SERVER="$HAPROXY_SERVICE_HOST:$HAPROXY_SERVICE_PORT"

sed -i -e "s/server doh-proxy .*/server doh-proxy ${DOH_SERVER}/" \
    /etc/haproxy.conf

if [ $# -eq 0 ]; then
    exec /usr/local/sbin/haproxy -V -f /etc/haproxy.conf # [-de] single threaded - poll is likely faster then epoll
fi
# /usr/local/sbin/haproxy -D -V -f /etc/haproxy.conf

[ "$1" = '--' ] && shift
exec "$@"
