#!/usr/bin/env bats
load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash

exampledotcom="q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB"

@test "139.99.222.72 GET DNS-over-HTTPS" {
    run curl "https://doh-2.seby.io/dns-query?dns=$exampledotcom"
    assert_success
}


@test "139.99.222.72 GET with content-type DNS-over-HTTPS" {
    run curl -H 'content-type: application/dns-message' "https://doh-2.seby.io/dns-query?dns=$exampledotcom"
    assert_success
}

@test "139.99.222.72 curl-url DNS-over-HTTPS" {
    run curl --doh-url https://doh-2.seby.io/dns-query https://ip.seby.io
    assert_success
}

@test "45.76.113.31 GET DNS-over-HTTPS" {
    run curl "https://doh-1.seby.io/dns-query?dns=$exampledotcom"
    assert_success
}

@test "45.76.113.31 GET with content-type DNS-over-HTTPS" {
    run curl -H 'content-type: application/dns-message' "https://doh-1.seby.io/dns-query?dns=$exampledotcom"
    assert_success
}

@test "45.76.113.31 curl-url DNS-over-HTTPS" {
    run curl --doh-url https://doh-1.seby.io/dns-query https://ip.seby.io
    assert_success
}
