#!/bin/sh

set -x

docker build -t publicarray/nsd nsd/
docker build -t publicarray/unbound unbound/
docker build -t publicarray/doh-proxy doh-proxy/
docker build -t publicarray/haproxy haproxy/
docker build -t publicarray/dnscrypt-wrapper dnscrypt-wrapper/

docker push publicarray/nsd
docker push publicarray/unbound
docker push publicarray/doh-proxy
docker push publicarray/haproxy
docker push publicarray/dnscrypt-wrapper
