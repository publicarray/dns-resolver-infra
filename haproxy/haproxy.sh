#!/bin/sh
set -e

exec /usr/local/sbin/haproxy -W -V -f /etc/haproxy.conf
