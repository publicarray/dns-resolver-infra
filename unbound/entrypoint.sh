#!/bin/sh
set -e

getServiceIP () {
    nslookup "$1" 2>/dev/null | grep -oE '(([0-9]{1,3})\.){3}(1?[0-9]{1,3})'
}

reserved=25
memoryMB=$(( $( (grep -F MemAvailable /proc/meminfo || grep -F MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) / 1024 ))
# https://fabiokung.com/2014/03/13/memory-inside-linux-containers/
dokerMemoryLimitMB=$(($(( $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / 1024)) / 1024))
if [ $dokerMemoryLimitMB -le $memoryMB ]; then
    memoryMB=$dokerMemoryLimitMB
fi

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

if [ -n "$(getServiceIP nsd)" ]; then
    NSD_SERVICE_HOST=$(getServiceIP nsd)
    NSD_SERVICE_PORT=53
fi

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

if [ $# -eq 0 ]; then
    exec /sbin/runsvdir -P /etc/service
fi

#------------------------ Optional add munin statistics -----------------------#
if [ "$1" = "munin" ]; then
    echo "==> Installing munin-node"
    apk update
    apk add munin-node
    mkdir -p /etc/munin/plugin-state
    echo "==> Installing contrib/unbound_munin_"
    wget https://raw.githubusercontent.com/NLnetLabs/unbound/master/contrib/unbound_munin_ -O /etc/munin/unbound_munin_
    chmod +x /etc/munin/unbound_munin_
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_by_class
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_by_flags
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_by_opcode
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_by_rcode
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_by_type
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_histogram
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_hits
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_memory
    ln -s /etc/munin/unbound_munin_ /etc/munin/plugins/unbound_munin_queue
    echo "==> Configuring munin-node"

    # Set a single IP to allow connections
    if [ -n "$2" ]; then
        echo "allow_ip: $2"
        allow_ip="allow ^$(echo "$2" | sed 's/\./\\./g')\$"
        echo "allow_ip: $allow_ip"
        echo "$allow_ip" >> /etc/munin/munin-node.conf
    fi
    groupadd _munin-node
    useradd -g _munin-node -s /dev/null -d /dev/null _munin-node
    chown -R _munin-node:_munin-node /etc/munin/
    sed \
        -re "s/user\\s{0,}\\root\\w/user _munin-node/" \
        -re "s/group\\s{0,}\\root\\w/group _munin-node/" \
        -i  "/etc/munin/munin-node.conf"
    # enable tls
    openssl req -x509 -nodes -sha256 -subj '/CN=localhost' -newkey rsa:4096 \
        -keyout /etc/ssl/munin.key \
        -out /etc/ssl/munin.pem \
        -days 99999999
    echo "tls enabled" >> /etc/munin/munin-node.conf
    echo "tls_verify_certificate no" >> /etc/munin/munin-node.conf
    echo "tls_private_key /etc/ssl/munin.key" >> /etc/munin/munin-node.conf
    echo "tls_certificate /etc/ssl/munin.pem" >> /etc/munin/munin-node.conf

cat << EOF > /etc/munin/plugin-conf.d/local.conf
[unbound*]
user root
env.statefile /etc/munin/plugin-state/unbound-state
env.unbound_conf /etc/unbound/unbound.conf
env.unbound_control /usr/local/sbin/unbound-control
env.spoof_warn 1000
env.spoof_crit 100000
EOF

    echo "==> Configuring unbound"
    sed \
        -re "s/# statistics-interval:\\s{0,}\\d{1,}\\w/statistics-interval: 1/" \
        -re "s/# extended-statistics:\\s{0,}\\d{1,}\\w/extended-statistics: 1/" \
        -re "s/# statistics-cumulative:\\s{0,}\\d{1,}\\w/statistics-cumulative: 1/" \
        -i  "/etc/unbound/unbound.conf"

    echo "==> Done"
    /usr/sbin/munin-node &
    exec /sbin/runsvdir -P /etc/service
    exit
fi

/sbin/runsvdir -P /etc/service &

[ "$1" = '--' ] && shift

exec "$@"
