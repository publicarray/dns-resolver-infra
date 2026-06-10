#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

@test "45.76.113.31 DNS-over-QUIC online" {
    run kdig @45.76.113.31 +quic +tls-host=dot.seby.io example.com
    assert_success
    assert_output -p "NOERROR"
}
