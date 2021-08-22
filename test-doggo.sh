#!/bin/sh

set +x
set -e

step() {
    echo "=====> $@ <====="
}

step 'test DNS -over-TLS:'

doggo @tls://dot.seby.io example.com
# doggo @tls://139.99.222.72 example.com
# doggo @tls://45.76.113.31 example.com

step 'test opennic:'

# domains="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"
# for domain in $domains; do
#     doggo @tls://139.99.222.72 $domain
#     doggo @tls://45.76.113.31 $domain
# done

step 'test DNS-over-HTTPS'
doggo @https://doh-2.seby.io/dns-query example.com
doggo @https://doh.seby.io:8443/dns-query example.com

step 'test for TLS 1.3'
echo "Q" | openssl s_client -connect 139.99.222.72:853 | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:853 | grep TLSv1.3
echo "Q" | openssl s_client -connect 139.99.222.72:443 | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:8443 | grep TLSv1.3

step 'test dnscrypt-proxy:'

# fetch the public-resolvers.md
doggo example.com @sdns://AQcAAAAAAAAADDQ1Ljc2LjExMy4zMSAIVGh4i6eKXqlF6o9Fg92cgD2WcDvKQJ7v_Wq4XrQsVhsyLmRuc2NyeXB0LWNlcnQuZG5zLnNlYnkuaW8
doggo example.com @sdns://AgcAAAAAAAAADDQ1Ljc2LjExMy4zMaA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OCAyhv9lpl-vMghe6hOIw3OLp-N4c8kGzOPEootMwqWJiBBkb2guc2VieS5pbzo4NDQzCi9kbnMtcXVlcnk
doggo example.com @sdns://AQcAAAAAAAAAEjEzOS45OS4yMjIuNzI6ODQ0MyDR7bj6zoAmbRaE1B8qTkCL_O84QCDMYPUgXZy5FRqUYRsyLmRuc2NyeXB0LWNlcnQuZG5zLnNlYnkuaW8
doggo example.com @sdns://AgcAAAAAAAAADTEzOS45OS4yMjIuNzKgPhoaD2xT8-l6SS1XCEtbmAcFnuBXqxUFh2_YP9o9uDggMob_ZaZfrzIIXuoTiMNzi6fjeHPJBszjxKKLTMKliYgRZG9oLTIuc2VieS5pbzo0NDMKL2Rucy1xdWVyeQ

step 'All Tests Passed!'
