#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

@test "45.76.113.31 DNSSEC bogus domain returns SERVFAIL" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io dnssec-failed.org
    assert_output -p "SERVFAIL"
}

@test "45.76.113.31 DNSSEC valid domain validates (ad flag)" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io +dnssec internetsociety.org
    assert_success
    assert_output -p "NOERROR"
    assert_output -p "flags:"
    assert_output -p " ad;"
}
