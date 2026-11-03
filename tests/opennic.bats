#!/usr/bin/env bats
load common

@test "45.76.113.31 opennic.glue DNS-over-TLS" {
    run dot_lookup opennic.glue
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}

@test "45.76.113.31 grep.geek DNS-over-TLS" {
    run dot_lookup grep.geek
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}

@test "45.76.113.31 nic.fur DNS-over-TLS" {
    run dot_lookup nic.fur
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}

@test "45.76.113.31 be.libre DNS-over-TLS" {
    run dot_lookup be.libre
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}

@test "45.76.113.31 register.null DNS-over-TLS" {
    run dot_lookup register.null
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}

@test "45.76.113.31 opennic.oz DNS-over-TLS" {
    run dot_lookup opennic.oz
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}

@test "45.76.113.31 www.opennic.chan DNS-over-TLS" {
    run dot_lookup www.opennic.chan
    assert_success
    assert_output -p "NOERROR"
    refute_output -p "answers=0"
}
