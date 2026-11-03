#!/bin/sh
set -e

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"1.1.1.1"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
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
