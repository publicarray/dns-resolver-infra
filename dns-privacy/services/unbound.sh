#!/bin/sh
set -e
exec 2>&1
# . /etc/envvars
exec /usr/local/sbin/unbound -d
