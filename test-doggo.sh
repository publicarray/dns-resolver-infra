#!/bin/sh
set -e

if ! command -v doggo >/dev/null; then
    echo "Please install doggo first:"
    echo "https://github.com/mr-karan/doggo"
    echo "Arch: yay -S doggo-bin"
    echo "macOS: brew install doggo"
    echo "Windows: scoop install doggo"
    echo "source: go install github.com/mr-karan/doggo/cmd/doggo@latest"
    exit 1
fi

step() {
    echo "=====> $* <====="
}

step 'Test DNS-over-TLS'
doggo @tls://dot.seby.io example.com

step 'Test opennic'
domains="opennic.glue grep.geek nic.fur be.libre register.null opennic.oz www.opennic.chan"
for domain in $domains; do
    doggo @tls://dot.seby.io "$domain"
done

step 'Test DNS-over-HTTPS'
doggo @https://doh.seby.io/dns-query example.com

step 'Test DNS-over-QUIC'
doggo @quic://dot.seby.io example.com

step 'Test for TLS 1.3'
echo "Q" | openssl s_client -connect 45.76.113.31:853 2>/dev/null | grep TLSv1.3
echo "Q" | openssl s_client -connect 45.76.113.31:443 2>/dev/null | grep TLSv1.3

step 'Done'
