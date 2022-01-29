#! /usr/bin/env bash

exec /usr/local/cargo/bin/doh-proxy -O \
                                    -H doh.seby.io \
                                    -l 0.0.0.0:3000 \
                                    -b 0.0.0.0:0 \
                                    -u 127.0.0.1:53 \
                                    -g "$PUBLIC_IP" \
                                    -I /opt/ssl/pkcs8.pem \
                                    -i /opt/ssl/fullchain-ecc.pem

# https://github.com/DNSCrypt/doh-server
# USAGE:
#     doh-proxy [FLAGS] [OPTIONS]

# FLAGS:
#     -O, --allow-odoh-post      Allow POST queries over ODoH even if they have been disabed for DoH
#     -K, --disable-keepalive    Disable keepalive
#     -P, --disable-post         Disable POST queries
#     -h, --help                 Prints help information
#     -V, --version              Prints version information

# OPTIONS:
#     -E, --err-ttl <err_ttl>                          TTL for errors, in seconds [default: 2]
#     -H, --hostname <hostname>                        Host name (not IP address) DoH clients will use to connect
#     -l, --listen-address <listen_address>            Address to listen to [default: 127.0.0.1:3000]
#     -b, --local-bind-address <local_bind_address>    Address to connect from
#     -c, --max-clients <max_clients>                  Maximum number of simultaneous clients [default: 512]
#     -C, --max-concurrent <max_concurrent>            Maximum number of concurrent requests per client [default: 16]
#     -X, --max-ttl <max_ttl>                          Maximum TTL, in seconds [default: 604800]
#     -T, --min-ttl <min_ttl>                          Minimum TTL, in seconds [default: 10]
#     -p, --path <path>                                URI path [default: /dns-query]
#     -g, --public-address <public_address>            External IP address DoH clients will connect to
#     -j, --public-port <public_port>                  External port DoH clients will connect to, if not 443
#     -u, --server-address <server_address>            Address to connect to [default: 9.9.9.9:53]
#     -t, --timeout <timeout>                          Timeout, in seconds [default: 10]
#     -I, --tls-cert-key-path <tls_cert_key_path>
#             Path to the PEM-encoded secret keys (only required for built-in TLS)
#     -i, --tls-cert-path <tls_cert_path>
#             Path to the PEM/PKCS#8-encoded certificates (only required for built-in TLS)
