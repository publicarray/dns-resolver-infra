#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

domains="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"

#@test "139.99.222.72 opennic.glue DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io opennic.glue
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 opennic.glue DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io opennic.glue
    assert_success
    assert_output -p "NOERROR;"
}

#@test "139.99.222.72 grep.geek DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io grep.geek
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 grep.geek DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io grep.geek
    assert_success
    assert_output -p "NOERROR;"
}


#@test "139.99.222.72 nic.fur DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io nic.fur
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 nic.fur DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io nic.fur
    assert_success
    assert_output -p "NOERROR;"
}

#@test "139.99.222.72 be.libre DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io be.libre
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 be.libre DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io be.libre
    assert_success
    assert_output -p "NOERROR;"
}


#@test "139.99.222.72 register.null DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io register.null
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 register.null DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io register.null
    assert_success
    assert_output -p "NOERROR;"
}

#@test "139.99.222.72 opennic.oz DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io opennic.oz
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 opennic.oz DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io opennic.oz
    assert_success
    assert_output -p "NOERROR;"
}

#@test "139.99.222.72 www.opennic.chan DNS-over-TLS" {
#    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io www.opennic.chan
#    assert_success
#    assert_output -p "NOERROR;"
#}
@test "45.76.113.31 www.opennic.chan DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io www.opennic.chan
    assert_success
    assert_output -p "NOERROR;"
}
