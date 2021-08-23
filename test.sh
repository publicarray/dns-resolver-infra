#!/bin/sh

# set +x
# set -e

# docker run -it --rm bats/bats:latest --tap
# docker run -it -v "$PWD":/opt/bats" --workdir /opt/bats bats/bats:latest test

yarn bats tests

exit

step() {
    echo "=====> $@ <====="
}
# kdig -d @139.99.222.72 +tls-ca +tls-host=dot.seby.io example.com
# kdig -d @45.76.113.31 +tls-ca +tls-host=dot.seby.io example.com

step 'test DNS -over-TLS:'
kdig @139.99.222.72 +tls-ca +tls-host=dot.seby.io example.com
kdig @45.76.113.31 +tls-ca +tls-host=dot.seby.io example.com

step 'test opennic:'

domains="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"
step '139.99.222.72'
for domain in $domains; do
    kdig @139.99.222.72 +short +tls-ca +tls-host=dot.seby.io $domain
done
step '45.76.113.31'
for domain in $domains; do
    kdig @45.76.113.31 +short +tls-ca +tls-host=dot.seby.io $domain
done
# curl -v 'https://doh-2.seby.io/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C
# curl -v 'https://doh.seby.io:8443/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' | hexdump -C

step 'test DNS-over-HTTPS'
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

# echo doggo install

doggo example.com @sdns://AQcAAAAAAAAADDQ1Ljc2LjExMy4zMSAIVGh4i6eKXqlF6o9Fg92cgD2WcDvKQJ7v_Wq4XrQsVhsyLmRuc2NyeXB0LWNlcnQuZG5zLnNlYnkuaW8
doggo example.com @sdns://AgcAAAAAAAAADDQ1Ljc2LjExMy4zMaA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OCAyhv9lpl-vMghe6hOIw3OLp-N4c8kGzOPEootMwqWJiBBkb2guc2VieS5pbzo4NDQzCi9kbnMtcXVlcnk
doggo example.com @sdns://AQcAAAAAAAAAEjEzOS45OS4yMjIuNzI6ODQ0MyDR7bj6zoAmbRaE1B8qTkCL_O84QCDMYPUgXZy5FRqUYRsyLmRuc2NyeXB0LWNlcnQuZG5zLnNlYnkuaW8
doggo example.com @sdns://AgcAAAAAAAAADTEzOS45OS4yMjIuNzKgPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDggMob_ZaZfrzIIXuoTiMNzi6fjeHPJBszjxKKLTMKliYgRZG9oLTIuc2VieS5pbzo0NDMKL2Rucy1xdWVyeQ

# fetch the public-resolvers.md
# dnscrypt-proxy -config tests/publicarray-au.toml -show-certs

# dnscrypt-proxy -config tests/publicarray-au-doh.toml &
# sleep 1
# dnscrypt-proxy -config tests/publicarray-au-doh.toml -resolve example.com
# kill $(jobs -lp | tail)
# dnscrypt-proxy -config tests/publicarray-au.toml &
# sleep 1
# dnscrypt-proxy -config tests/publicarray-au.toml -resolve example.com
# kill $(jobs -lp | tail)
# dnscrypt-proxy -config tests/publicarray-au2-doh.toml &
# sleep 1
# dnscrypt-proxy -config tests/publicarray-au2-doh.toml -resolve example.com
# kill $(jobs -lp | tail)
# dnscrypt-proxy -config tests/publicarray-au2.toml &
# sleep 1
# dnscrypt-proxy -config tests/publicarray-au2.toml -resolve example.com
# kill $(jobs -lp | tail)
# sleep 1
# jobs -l
# killall dnscrypt-proxy
step 'All Tests Passed!'
