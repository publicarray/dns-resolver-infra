#!/bin/sh

set +x
set -e

if ! command -v dog; then
    echo "Please install dog first:"
    echo "https://github.com/ogham/dog/"
    exit
fi

step() {
    echo "=====> $@ <====="
}

step 'test DNS -over-TLS:'
dog -S @dot.seby.io example.com
# dog -S @139.99.222.72 example.com
# dog -S @45.76.113.31 example.com

step 'test opennic:'

# domains="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"
for domain in $domains; do
    dog -S @dot.seby.io $domain
    # dog -S @139.99.222.72 $domain
    # dog -S @45.76.113.31 $domain
done

step 'test DNS-over-HTTPS'
dog -H @https://doh.seby.io/dns-query example.com
# dog -H @https://doh-2.seby.io/dns-query example.com
dog -H @https://doh-1.seby.io/dns-query example.com

step 'test for TLS 1.3'
# echo "Q" | openssl s_client -connect 139.99.222.72:853 | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:853 | grep TLSv1.3
# echo "Q" | openssl s_client -connect 139.99.222.72:443 | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:443 | grep TLSv1.3

# step 'test dnscrypt-proxy:'

# # fetch the public-resolvers.md
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
