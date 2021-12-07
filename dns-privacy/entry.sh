#! /bin/bash
# env

generate_cert() {
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue \
        --domain "$DOMAIN" \
        --dns dns_cf \
        --dnssleep 60 \
        --keylength ec-384 \
        --fullchain-file /opt/ssl/fullchain-ecc.pem \
        --key-file /opt/ssl/key-ecc.pem \
        --ca-file /opt/ssl/ca-ecc.pem \
        --cert-file /opt/ssl/cert-ecc.pem \
        --reloadcmd 'cat /opt/ssl/key-ecc.pem > cat /opt/ssl/fullchain-ecc.pem > /opt/ssl/fullchain-key.pem.ecdsa && openssl pkcs8 -topk8 -nocrypt -in /opt/ssl/key-ecc.pem -out /opt/ssl/pkcs8.pem && sv force-restart unbound'
    # --force --test

    # Clear values
    export CF_Key=
    export CF_Token=
    export CF_Account_ID=
    export CF_Zone_ID=
}

optimise_unbound_memory() {
    reserved=128 # Megabyte
    memoryMB=$(( $( (grep -F MemAvailable /proc/meminfo || grep -F MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) / 1024 ))
    # https://fabiokuARG AUTO_UPGRADE=1ng.com/2014/03/13/memory-inside-linux-containers/
    if [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
        dokerMemoryLimitMB=$(($(( $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / 1024)) / 1024))
        if [ $dokerMemoryLimitMB -le $memoryMB ]; then
            memoryMB=$dokerMemoryLimitMB
        fi
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
        -i  "/etc/unbound/unbound.conf"
}

# Start
generate_cert
if [ ! -f /etc/unbound/unbound_server.pem ]; then
    unbound-control-setup
fi
optimise_unbound_memory
echo "==> Done configuring unbound"

# Start Services
find /etc/sv -mindepth 1 -maxdepth 1 -type d | while read -r service; do
    echo "==> Enable $service"
    ln -s -f "$service" "/var/service/"
done
# exec /etc/runit/2 </dev/null >/dev/null 2>/dev/null

if [ "$1" = '--' ] && shift; then
    runsvdir -P /var/service &
    sv status /var/service/*
    exec "$@"
fi

exec runsvdir -P /var/service