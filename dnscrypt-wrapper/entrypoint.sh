#!/bin/sh
set -e

UNBOUND_SERVICE_HOST=${UNBOUND_SERVICE_HOST-"9.9.9.9"}
UNBOUND_SERVICE_PORT=${UNBOUND_SERVICE_PORT-"53"}
#-r "${UNBOUND_SERVICE_HOST}:${UNBOUND_SERVICE_PORT}"--listen-address 0.0.0.0:443

# if [ $# -eq 0 ]; then
#     # chroot /opt/dnscrypt /usr/local/sbin/dnscrypt-wrapper --user=_dnscrypt-wrapper -h
#     # chroot /etc/dnscrypt-wrapper/run/ /usr/local/sbin/dnscrypt-wrapper --user=_dnscrypt-wrapper
#     # exec /usr/local/sbin/dnscrypt-wrapper --user=_dnscrypt-wrapper -h
#     exec /usr/local/sbin/anscript-auto -h
# fi

[ "$1" = '--' ] && shift

exec "$@"
# exec /usr/local/sbin/anscript-auto "$@"
# exec /usr/local/sbin/dnscrypt-wrapper --user="$DNSCRYPT_USER" "$@"

# empty cmd
# -> help

# cmd of -d dns.seby.io
# -> run

# cmd of -d dns.seby.io --init
