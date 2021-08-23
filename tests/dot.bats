#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

@test "139.99.222.72 DNS-over-TLS online" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io example.com
    assert_success
    assert_output -p "NOERROR;"
}

@test "45.76.113.31 DNS-over-TLS online" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io example.com
    assert_success
    assert_output -p "NOERROR;"
}
