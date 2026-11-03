#!/usr/bin/env bats
load common

@test "45.76.113.31 DNS-over-QUIC online" {
    openssl s_client -help 2>&1 | grep -q -- '-quic' || skip "openssl s_client without QUIC support (needs OpenSSL 3.5+)"
    run doq_lookup example.com
    assert_success
    assert_output -p "NOERROR"
}
