#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash
load dns

@test "45.76.113.31 DNSSEC bogus domain returns SERVFAIL" {
    run dot_lookup dnssec-failed.org
    assert_output -p "SERVFAIL"
}

@test "45.76.113.31 DNSSEC valid domain validates (ad flag)" {
    run dot_lookup internetsociety.org
    assert_success
    assert_output -p "NOERROR ad"
}
