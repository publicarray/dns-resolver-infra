FROM docker.io/rust:latest as build-rust
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
ENV REVISION 1
ENV RUSTFLAGS "-C link-arg=-s"

# https://github.com/DNSCrypt/doh-server/tags
# https://crates.io/crates/doh-proxy
ARG DOH_VERSION=0.9.2
RUN cargo install doh-proxy --version $DOH_VERSION && \
    strip --strip-all /usr/local/cargo/bin/doh-proxy

# https://github.com/DNSCrypt/encrypted-dns-server
# https://crates.io/crates/encrypted-dns
ARG DNSCRYPT_VERSION=0.9.1
RUN cargo install encrypted-dns --version $DNSCRYPT_VERSION && \
    strip --strip-all /usr/local/cargo/bin/encrypted-dns

# ---- unbound
FROM ubuntu:21.10 as build
WORKDIR /tmp
ENV UNBOUND_BUILD_DEPS   curl make build-essential wget libevent-dev libexpat1-dev libnghttp2-dev autoconf file libssl-dev byacc ca-certificates
ARG UNBOUND_VERSION=1.13.2
ARG UNBOUND_SHA256=0a13b547f3b92a026b5ebd0423f54c991e5718037fd9f72445817f6a040e1a83
ARG UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz

WORKDIR /tmp
RUN apt-get update && apt-get install -qy --no-install-recommends $UNBOUND_BUILD_DEPS && \ 
    rm -fr /var/cache/apt/* /var/lib/apt/lists/* /var/log/apt/* /var/log/*.log

RUN update-ca-certificates 2> /dev/null || true

# --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu
RUN set -x && \
    wget -O unbound.tar.gz $UNBOUND_DOWNLOAD_URL && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    ./configure --with-conf-file=/etc/unbound/unbound.conf --with-run-dir=/etc/unbound \
    --with-pthreads --with-username=_unbound --with-libevent --with-libnghttp2 \
    CFLAGS="-O2 -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" && \
    make -j"$(getconf _NPROCESSORS_ONLN)" install && \
    ls /usr/local/lib/

#------------------------------------------------------------------------------#
FROM ubuntu:21.10 as dns-privacy
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
ENV RUNTIME_DEPS bash util-linux coreutils wget curl bc findutils grep socat cron nano libssl1.1 dnsutils ldnsutils file libevent-2.1 nghttp2 expat ca-certificates runit runit-helper jed
RUN apt-get update && apt-get -qy dist-upgrade && apt-get -qy clean && \
    apt-get install -qy --no-install-recommends $RUNTIME_DEPS && \
    rm -fr /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/* /var/log/apt/* /var/log/*.log

RUN update-ca-certificates 2> /dev/null || true
ENV EDITOR=nano

# acme.sh
RUN curl https://get.acme.sh | sh -s

# unbound 
# https://github.com/NLnetLabs/unbound/blob/master/configure#L2807
ARG LIBUNBOUND_CURRENT=8
# {LIBUNBOUND_CURRENT}.{LIBUNBOUND_AGE}.{LIBUNBOUND_REVISION}
ARG LIBUNBOUND_VERSION=${LIBUNBOUND_CURRENT}.1.13

COPY --from=build /usr/local/sbin/unbound /usr/local/sbin/unbound
COPY --from=build /usr/local/sbin/unbound-checkconf /usr/local/sbin/unbound-checkconf
COPY --from=build /usr/local/sbin/unbound-control /usr/local/sbin/unbound-control
COPY --from=build /usr/local/sbin/unbound-host /usr/local/sbin/unbound-host
COPY --from=build /usr/local/sbin/unbound-anchor /usr/local/sbin/unbound-anchor
COPY --from=build /usr/local/sbin/unbound-control-setup /usr/local/sbin/unbound-control-setup
COPY --from=build /usr/local/lib/libunbound.so.${LIBUNBOUND_VERSION} /usr/local/lib/libunbound.so.${LIBUNBOUND_VERSION}

RUN set -x && \
    cd /usr/local/lib/ && \
    ln -sf libunbound.so.${LIBUNBOUND_VERSION} libunbound.so.${LIBUNBOUND_CURRENT} && \
    ln -sf libunbound.so.${LIBUNBOUND_VERSION} libunbound.so && \
    /sbin/ldconfig -v && \
    cd && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /dev/null _unbound && \
    mkdir -p /etc/service/unbound /etc/unbound/run && \
    unbound-anchor -a /etc/unbound/run/root.key || true && \
    chown _unbound:_unbound /etc/unbound/run && \
    chown _unbound:_unbound /etc/unbound/run/root.key && \
    wget -O /etc/unbound/root.hints https://www.internic.net/domain/named.root

COPY unbound.conf /etc/unbound/unbound.conf
COPY opennic.conf /etc/unbound/opennic.conf
RUN unbound -h || true
RUN unbound-checkconf /etc/unbound/unbound.conf || true

# doh
COPY --from=build-rust /usr/local/cargo/bin/doh-proxy /usr/local/cargo/bin/doh-proxy

# dnscrypt
COPY --from=build-rust /usr/local/cargo/bin/encrypted-dns /usr/local/cargo/bin/encrypted-dns
RUN groupadd _encrypted-dns && \
    useradd -g _encrypted-dns -s /dev/null -d /dev/null _encrypted-dns && \
    mkdir -p /opt/encrypted-dns/keys && \
    chown -R _encrypted-dns:_encrypted-dns /opt/encrypted-dns/keys 2>/dev/null && \
    wget -O /opt/encrypted-dns/undelegated.txt https://raw.githubusercontent.com/DNSCrypt/encrypted-dns-server/master/undelegated.txt
COPY encrypted-dns.toml /opt/encrypted-dns/encrypted-dns.toml

# services
RUN mkdir -p \
    /var/service \
    /etc/sv/doh \
    /etc/sv/dnscrypt \
    /etc/sv/unbound

COPY services/doh.sh /etc/sv/doh/run
COPY services/dnscrypt.sh /etc/sv/dnscrypt/run
COPY services/unbound.sh /etc/sv/unbound/run

# DoH / dnscrypt
EXPOSE 443/udp 443/tcp
# DoT
EXPOSE 853/udp 853/tcp
# stats
EXPOSE 9100/tcp

COPY entry.sh /
ENTRYPOINT ["/entry.sh"]
#CMD [""]

# HEALTHCHECK --start-period=1m --interval=2m \
# CMD ["drill", "-D", "-Q", ".", "@127.0.0.1", "SOA"]

# Metadata
LABEL org.opencontainers.image.title="dns-privacy" \
        org.opencontainers.image.description="DNS resolver with privacy protcolls." \
        org.opencontainers.image.authors="publicarray"