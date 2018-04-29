#!/bin/sh

sleep 300

sv check dnscrypt-wrapper || sv force-restart dnscrypt-wrapper

KEYS_DIR="/opt/dnscrypt/etc/keys"
GRACE_PERIOD=60

provider_key=$(cat "${KEYS_DIR}/public.key.txt")
provider_name=$(cat "${KEYS_DIR}/provider_name")

drill -p 443 -Q TXT "$provider_name" @127.0.0.1 || \
sv force-restart dnscrypt-wrapper
