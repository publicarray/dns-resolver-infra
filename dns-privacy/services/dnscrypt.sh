#! /usr/bin/env bash

sed -i \
    -e "s/provider_name\s=.*/provider_name = \"$PROVIDER_NAME\"/" \
    -e "s/external\s=\s\"0\.0\.0\.0.*\"/external = \"$PUBLIC_IP4:433\"/g" \
    -e "s/external\s=\s\"\[::\].*\"/external = \"$PUBLIC_IP6:433\"/g" \
    /opt/encrypted-dns/encrypted-dns.toml

if [ -f "/opt/encrypted-dns/keys/provider-info.txt" ];then
    cat /opt/encrypted-dns/keys/provider-info.txt
fi

exec /usr/local/cargo/bin/encrypted-dns --config /opt/encrypted-dns/encrypted-dns.toml
