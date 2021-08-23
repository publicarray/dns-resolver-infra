#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

openssl_client() {
    echo "Q" | openssl s_client -connect $@
}

@test "139.99.222.72 TLS 1.3 support DNS-over-TLS" {
    run openssl_client 139.99.222.72:853
    assert_output -p "TLSv1.3"
}

@test "139.99.222.72 TLS 1.3 support DNS-over-HTTPS" {
    run openssl_client 139.99.222.72:443
    assert_output -p "TLSv1.3"
}

@test "45.76.113.31 TLS 1.3 support DNS-over-TLS" {
    run openssl_client 45.76.113.31:853
    assert_output -p "TLSv1.3"
}

@test "45.76.113.31 TLS 1.3 support DNS-over-HTTPS" {
    run openssl_client 45.76.113.31:8443
    assert_output -p "TLSv1.3"
}
