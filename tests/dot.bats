#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash
load dns

@test "45.76.113.31 DNS-over-TLS online" {
    run dot_lookup example.com
    assert_success
    assert_output -p "NOERROR"
}
