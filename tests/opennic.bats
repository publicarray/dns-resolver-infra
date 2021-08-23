#!/usr/bin/env bats

domains="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"

@test "139.99.222.72 opennic.glue DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io opennic.glue
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 opennic.glue DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io opennic.glue
    [ "$status" -eq 0 ]
}

@test "139.99.222.72 grep.geek DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io grep.geek
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 grep.geek DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io grep.geek
    [ "$status" -eq 0 ]
}


@test "139.99.222.72 nic.fur DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io nic.fur
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 nic.fur DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io nic.fur
    [ "$status" -eq 0 ]
}

@test "139.99.222.72 be.libre DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io be.libre
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 be.libre DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io be.libre
    [ "$status" -eq 0 ]
}


@test "139.99.222.72 register.null DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io register.null
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 register.null DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io register.null
    [ "$status" -eq 0 ]
}

@test "139.99.222.72 opennic.oz DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io opennic.oz
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 opennic.oz DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io opennic.oz
    [ "$status" -eq 0 ]
}

@test "139.99.222.72 www.opennic.chan DNS-over-TLS" {
    run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io www.opennic.chan
    [ "$status" -eq 0 ]
}
@test "45.76.113.31 www.opennic.chan DNS-over-TLS" {
    run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io www.opennic.chan
    [ "$status" -eq 0 ]
}
