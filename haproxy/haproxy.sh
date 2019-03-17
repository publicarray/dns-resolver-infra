#!/bin/sh
set -e

exec /usr/local/sbin/haproxy -V -f /etc/haproxy.conf
