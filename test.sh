#!/bin/sh

set +x
set -e

function step {
    echo "***** $@ ****"
}
# kdig -d @139.99.222.72 +tls-ca +tls-host=dot.seby.io example.com
# kdig -d @45.76.113.31 +tls-ca +tls-host=dot.seby.io example.com

step 'test DNS -over-TLS:'
kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io example.com
kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io example.com

step 'test opennic:'

doamins="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"
for domain in $domains; do
    kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io NS $domain
    kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io NS $domain
done

# curl -v 'https://doh-2.seby.io/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C
# curl -v 'https://doh.seby.io:8443/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C

step 'test opennic: DNS-over-HTTPS'
# curl -so /dev/null --doh-url https://doh.seby.io:8443/dns-query https://example.com
curl 'https://doh-2.seby.io/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C
curl 'https://doh.seby.io:8443/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C
curl -H 'content-type: application/dns-message' 'https://doh-2.seby.io/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C
curl -H 'content-type: application/dns-message' 'https://doh.seby.io:8443/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C
curl --doh-url https://doh-2.seby.io/dns-query https://ip.seby.io
curl --doh-url https://doh.seby.io:8443/dns-query https://ip.seby.io

step 'test for TLS 1.3'
echo "Q" | openssl s_client -connect 139.99.222.72:853 | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:853 | grep TLSv1.3
echo "Q" | openssl s_client -connect 139.99.222.72:443 | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:8443 | grep TLSv1.3

step 'test dnscrypt-proxy:'

# fetch the public-resolvers.md
dnscrypt-proxy -config tests/publicarray-au.toml -show-certs

dnscrypt-proxy -config tests/publicarray-au-doh.toml &
sleep 1
dnscrypt-proxy -config tests/publicarray-au-doh.toml -resolve example.com
kill $(jobs -lp | tail)
dnscrypt-proxy -config tests/publicarray-au.toml &
sleep 1
dnscrypt-proxy -config tests/publicarray-au.toml -resolve example.com
kill $(jobs -lp | tail)
dnscrypt-proxy -config tests/publicarray-au2-doh.toml &
sleep 1
dnscrypt-proxy -config tests/publicarray-au2-doh.toml -resolve example.com
kill $(jobs -lp | tail)
dnscrypt-proxy -config tests/publicarray-au2.toml &
sleep 1
dnscrypt-proxy -config tests/publicarray-au2.toml -resolve example.com
kill $(jobs -lp | tail)
sleep 1
jobs -l
# killall dnscrypt-proxy
step 'All Tests Passed'
