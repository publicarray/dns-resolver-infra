#!/usr/bin/env bats
load common

exampledotcom="q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB"

@test "45.76.113.31 GET DNS-over-HTTPS" {
    run curl -sf "https://doh-1.seby.io/dns-query?dns=$exampledotcom"
    assert_success
}

@test "45.76.113.31 GET with content-type DNS-over-HTTPS" {
    run curl -sf -H 'content-type: application/dns-message' "https://doh-1.seby.io/dns-query?dns=$exampledotcom"
    assert_success
}

@test "45.76.113.31 curl-url DNS-over-HTTPS" {
    run curl -sf --doh-url https://doh-1.seby.io/dns-query https://ip.seby.io
    assert_success
}

@test "45.76.113.31 POST DNS-over-HTTPS" {
    run bash -c "printf '%s' '$exampledotcom' | base64 -d | curl -s -f -H 'content-type: application/dns-message' --data-binary @- 'https://doh-1.seby.io/dns-query'"
    assert_success
}

@test "45.76.113.31 GET DNS-over-HTTPS over HTTP/3 (QUIC)" {
    curl -V | grep -q HTTP3 || skip "curl built without HTTP/3"
    run curl -s -m 10 --http3-only -o /dev/null -w '%{http_version} %{http_code}' "https://doh-1.seby.io/dns-query?dns=$exampledotcom"
    assert_success
    assert_output "3 200"
}

@test "45.76.113.31 DNS-over-HTTPS advertises HTTP/3 via alt-svc" {
    run curl -sI -m 10 "https://doh-1.seby.io/dns-query?dns=$exampledotcom"
    assert_success
    assert_output -p 'alt-svc: h3=":443"'
}
