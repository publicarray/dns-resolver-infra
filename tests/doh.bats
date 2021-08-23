#!/usr/bin/env bats
exampledotcom="q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB"

@test "139.99.222.72 GET DNS-over-HTTPS" {
  run curl "https://doh-2.seby.io/dns-query?dns=$exampledotcom"
  [ "$status" -eq 0 ]
}


@test "139.99.222.72 GET with content-type DNS-over-HTTPS" {
  run curl -H 'content-type: application/dns-message' "https://doh-2.seby.io/dns-query?dns=$exampledotcom"
  [ "$status" -eq 0 ]
}

@test "139.99.222.72 curl-url DNS-over-HTTPS" {
  run curl --doh-url https://doh-2.seby.io/dns-query https://ip.seby.io
  [ "$status" -eq 0 ]
}

@test "45.76.113.31 GET DNS-over-HTTPS" {
  run curl "https://doh.seby.io:8443/dns-query?dns=$exampledotcom"
  [ "$status" -eq 0 ]
}

@test "45.76.113.31 GET with content-type DNS-over-HTTPS" {
  run curl -H 'content-type: application/dns-message' "https://doh.seby.io:8443/dns-query?dns=$exampledotcom"
  [ "$status" -eq 0 ]
}

@test "45.76.113.31 curl-url DNS-over-HTTPS" {
  run curl --doh-url https://doh.seby.io:8443/dns-query https://ip.seby.io
  [ "$status" -eq 0 ]
}

# @test "http_head_cmd: with curl performs a head request" {
#     respond_to "which curl" "echo /usr/bin/curl"
#     url="https://foo.com"
#     respond_to "curl -sIL \"https://foo.com\"" "cat $fixtures/http-head-curl.txt"
#     run http_head_cmd "$url"
#     [ "$status" -eq 0 ]
#     [[ 'curl -sIL "https://foo.com"' == $output ]]
# }
