#!/bin/sh
# Borrowed from: https://github.com/faisyl/alpine-runit/blob/master/start_runit

set -e

if [ $# -eq 0 ]; then
    exec /sbin/runsvdir -P /etc/service
fi

/sbin/runsvdir -P /etc/service &

[ "$1" = '--' ] && shift

exec $@
