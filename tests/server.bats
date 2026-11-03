#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

setup() {
    if ! docker inspect --type container haproxy >/dev/null 2>&1; then
        skip "haproxy container not running on this host"
    fi
}

@test "haproxy runs in master-worker mode" {
    run docker exec haproxy pidof haproxy
    assert_success
    [ "$(echo "$output" | wc -w)" -ge 2 ]
}

@test "haproxy backends use static IPs" {
    run docker exec haproxy grep -E 'server (dns|doh-proxy) ' /etc/haproxy.conf
    assert_success
    assert_output -p "server dns 172.30.53.53:5353"
    assert_output -p "server doh-proxy 172.30.53.80:3000"
}
