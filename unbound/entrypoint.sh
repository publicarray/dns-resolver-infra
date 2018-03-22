#!/bin/sh
set -e
# export > /etc/envvars

reserved=25
memoryMB=$(( $( (grep -F MemAvailable /proc/meminfo || grep -F MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) / 1024 ))
if [ $memoryMB -le $reserved ]; then
    echo "Not enough memory" >&2
    exit 1
fi
memory=$(($((memoryMB / 4)) - reserved))

nproc=$(nproc)
if [ "$nproc" -gt 1 ]; then
    threads=$((nproc - 1))
else
    threads=1
fi

NSD_SERVICE_HOST=${NSD_SERVICE_HOST-"127.0.0.1"}
NSD_SERVICE_PORT=${NSD_SERVICE_PORT-"552"}

sed \
    -re "s/num-threads:\\s{0,}\\d{1,}\\w/num-threads: ${threads}/" \
    -re "s/msg-cache-slabs:\\s{0,}\\d{1,}\\w/msg-cache-size: ${threads}/" \
    -re "s/rrset-cache-slabs:\\s{0,}\\d{1,}\\w/rrset-cache-slabs: ${threads}/" \
    -re "s/key-cache-slabs:\\s{0,}\\d{1,}\\w/key-cache-slabs: ${threads}/" \
    -re "s/infra-cache-slabs:\\s{0,}\\d{1,}\\w/infra-cache-slabs: ${threads}/" \
    -re "s/msg-cache-size:\\s{0,}\\d{1,}\\w/msg-cache-size: ${memory}m/" \
    -re "s/rrset-cache-size:\\s{0,}\\d{1,}\\w/rrset-cache-size: $((memory * 2))m/" \
    -re "s/key-cache-size:\\s{0,}\\d{1,}\\w/key-cache-size: $((memory / 2))m/" \
    -re "s/neg-cache-size:\\s{0,}\\d{1,}\\w/neg-cache-size: $((memory / 2))m/" \
    -e  "s/stub-addr: \"127.0.0.1@552\"/stub-addr: \"${NSD_SERVICE_HOST}@${NSD_SERVICE_PORT}\"/g" \
    -i  "/etc/unbound/unbound.conf"

if [ ! -f /etc/unbound/unbound_server.pem ]; then
    unbound-control-setup
fi

# Borrowed from: https://github.com/faisyl/alpine-runit/blob/master/start_runit
if [ $# -eq 0 ]; then
    exec /sbin/runsvdir -P /etc/service
fi

/sbin/runsvdir -P /etc/service &

[ "$1" = '--' ] && shift

exec "$@"
