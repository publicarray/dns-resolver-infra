#!/usr/bin/env bats
load common

https_redirect() {
    curl -s -m 10 -o /dev/null -w '%{http_code} %{redirect_url}' "$@"
}

@test "45.76.113.31 HTTPS doh.seby.io redirects to dns.seby.io" {
    run https_redirect https://doh.seby.io/
    assert_success
    assert_output "301 https://dns.seby.io/"
}

@test "45.76.113.31 HTTPS dot.seby.io redirects to dns.seby.io" {
    run https_redirect https://dot.seby.io/
    assert_success
    assert_output "301 https://dns.seby.io/"
}

@test "45.76.113.31 HTTPS bare IP redirects to ntppool" {
    run https_redirect -k https://45.76.113.31/
    assert_success
    assert_output "301 https://www.ntppool.org/en/"
}

@test "45.76.113.31 HTTPS unknown host redirects to ntppool" {
    run https_redirect -k --resolve pool.ntp.org:443:45.76.113.31 https://pool.ntp.org/
    assert_success
    assert_output "301 https://www.ntppool.org/en/"
}

@test "45.76.113.31 HTTPS /dns-query is not redirected" {
    run https_redirect "https://doh.seby.io/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB"
    assert_success
    assert_output "200 "
}
