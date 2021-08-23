#!/usr/bin/env bats

@test "139.99.222.72 DNS-over-TLS online" {
  run kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io example.com
  [ "$status" -eq 0 ]
}

@test "45.76.113.31 DNS-over-TLS online" {
  run kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io example.com
  [ "$status" -eq 0 ]
}
