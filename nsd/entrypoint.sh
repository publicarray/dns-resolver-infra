#!/bin/sh
set -e

if [ ! -f /etc/nsd/nsd_server.pem ]; then
    nsd-control-setup
fi

[ "$1" = '--' ] && shift

exec /usr/local/sbin/nsd "$@"
