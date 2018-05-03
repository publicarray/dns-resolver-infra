#!/bin/sh
set -e

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"9.9.9.9"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
export RESOLVER="$UNBOUND_SERVICE_HOST:$UNBOUND_SERVICE_PORT"

if [ $# -eq 0 ]; then
    exec /usr/local/bin/doh-proxy -u "${RESOLVER}" -l 0.0.0.0:3000
fi

[ "$1" = '--' ] && shift

exec /usr/local/bin/doh-proxy "$@"
