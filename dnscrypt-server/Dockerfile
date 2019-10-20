FROM rustlang/rust:nightly AS encrypted-dns-build
ENV REVISION 0
SHELL ["/bin/sh", "-x", "-c"]
ENV RUSTFLAGS "-C link-arg=-s"
RUN cargo install encrypted-dns && \
    strip --strip-all /usr/local/cargo/bin/encrypted-dns

#------------------------------------------------------------------------------#
FROM debian:buster-slim
LABEL maintainer "publicarray"
LABEL name "dnscrypt-server"
LABEL description "https://github.com/jedisct1/encrypted-dns-server - Basically https://github.com/DNSCrypt/dnscrypt-server-docker minus unbound"
SHELL ["/bin/sh", "-x", "-c"]
WORKDIR /tmp
ENV RUN_DEPS bash runit runit-helper coreutils findutils grep ca-certificates libevent-2.1 libssl1.1 expat
RUN apt-get update && \
    apt-get install -qy --no-install-recommends $RUN_DEPS && \
    rm -fr /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/* /var/log/apt/* /var/log/*.log
RUN update-ca-certificates 2> /dev/null || true

COPY --from=encrypted-dns-build /usr/local/cargo/bin/encrypted-dns /usr/local/bin/encrypted-dns

RUN mkdir -p /opt/encrypted-dns/empty \
        /etc/service/watchdog \
        /etc/service/key-rotation \
        /etc/service/dnscrypt-wrapper && \
    groupadd _encrypted-dns && \
    useradd -g _encrypted-dns -s /etc -d /opt/encrypted-dns/empty _encrypted-dns && \
    mkdir -m 700 -p /opt/encrypted-dns/etc/keys && \
    mkdir -m 700 -p /opt/encrypted-dns/etc/lists && \
    chown _encrypted-dns:_encrypted-dns /opt/encrypted-dns/etc/keys && \
    mkdir -m 700 -p /opt/dnscrypt-wrapper/etc/keys && \
    mkdir -m 700 -p /opt/dnscrypt-wrapper/etc/lists && \
    chown _encrypted-dns:_encrypted-dns /opt/dnscrypt-wrapper/etc/keys

COPY encrypted-dns.toml.in /opt/encrypted-dns/etc/
COPY encrypted-dns.sh /etc/service/encrypted-dns/run
COPY entrypoint.sh /

VOLUME ["/opt/encrypted-dns/etc/keys"]

EXPOSE 443/udp 443/tcp

RUN /usr/local/bin/encrypted-dns --version

CMD ["/entrypoint.sh", "start"]

ENTRYPOINT ["/entrypoint.sh"]
