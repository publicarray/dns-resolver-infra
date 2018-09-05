<p align="center">
    <img src="logo/icon-transparent.svg" alt="DNS Resolver Infrastructure" width="300">
</p>

# DNS Resolver Infrastructure

## Infrastructure Overview

<br>
<p align="center">
    <img src="dns-infra.png" alt="Infrastructure" style="max-width:100%;" width="900">
</p>

* [acme.sh](https://github.com/Neilpang/acme.sh) (TLS certificate generation for haproxy)
* [nsd](https://www.nlnetlabs.nl/projects/nsd/) ([OpenNIC](https://www.opennic.org/)) [![Docker Pulls](https://img.shields.io/docker/pulls/publicarray/nsd.svg?maxAge=86400)](https://hub.docker.com/r/publicarray/nsd/) [![MicroBadger Size](https://images.microbadger.com/badges/image/publicarray/nsd.svg)](https://microbadger.com/images/publicarray/nsd)
  * [unbound](https://unbound.nlnetlabs.nl/) (DNS Resolver) [![Docker Pulls](https://img.shields.io/docker/pulls/publicarray/unbound.svg?maxAge=86400)](https://hub.docker.com/r/publicarray/unbound/) [![MicroBadger Size](https://images.microbadger.com/badges/image/publicarray/unbound.svg)](https://microbadger.com/images/publicarray/unbound)
    * [dnscrypt-wrapper](https://github.com/cofyc/dnscrypt-wrapper) (dnscrypt) [![Docker Pulls](https://img.shields.io/docker/pulls/publicarray/dnscrypt-wrapper.svg?maxAge=86400)](https://hub.docker.com/r/publicarray/dnscrypt-wrapper/) [![MicroBadger Size](https://images.microbadger.com/badges/image/publicarray/dnscrypt-wrapper.svg)](https://microbadger.com/images/publicarray/dnscrypt-wrapper)
    * [doh-proxy](https://github.com/jedisct1/rust-doh) [![Docker Pulls](https://img.shields.io/docker/pulls/publicarray/doh-proxy.svg?maxAge=86400)](https://hub.docker.com/r/publicarray/doh-proxy/) [![MicroBadger Size](https://images.microbadger.com/badges/image/publicarray/doh-proxy.svg)](https://microbadger.com/images/publicarray/doh-proxy)
      * [haproxy](http://www.haproxy.org/) (DHS-over-HTTPS) [![Docker Pulls](https://img.shields.io/docker/pulls/publicarray/haproxy.svg?maxAge=86400)](https://hub.docker.com/r/publicarray/haproxy/) [![MicroBadger Size](https://images.microbadger.com/badges/image/publicarray/haproxy.svg)](https://microbadger.com/images/publicarray/haproxy)
    * [haproxy](http://www.haproxy.org/) (DNS-over-TLS) [![Docker Pulls](https://img.shields.io/docker/pulls/publicarray/haproxy.svg?maxAge=86400)](https://hub.docker.com/r/publicarray/haproxy/) [![MicroBadger Size](https://images.microbadger.com/badges/image/publicarray/haproxy.svg)](https://microbadger.com/images/publicarray/haproxy)

## Getting started

* [Usage with Docker-Swarm](docker.md)
* [Usage with Kubernetes](kube.md)
