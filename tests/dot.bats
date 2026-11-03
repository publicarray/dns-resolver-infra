#!/usr/bin/env bats
load common

@test "45.76.113.31 DNS-over-TLS online" {
    run dot_lookup example.com
    assert_success
    assert_output -p "NOERROR"
}
