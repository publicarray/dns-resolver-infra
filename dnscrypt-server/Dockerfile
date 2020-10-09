FROM rustlang/rust:nightly AS encrypted-dns-build
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
ENV REVISION 1
ENV VERSION 0.3.17
SHELL ["/bin/sh", "-x", "-c"]
ENV RUSTFLAGS "-C link-arg=-s"
RUN cargo install encrypted-dns --version $VERSION && \
    strip --strip-all /usr/local/cargo/bin/encrypted-dns

#------------------------------------------------------------------------------#
FROM ubuntu:20.04
LABEL maintainer="publicarray"
LABEL name="dnscrypt-server"
LABEL description="https://github.com/jedisct1/encrypted-dns-server - Basically https://github.com/DNSCrypt/dnscrypt-server-docker minus unbound"
SHELL ["/bin/sh", "-x", "-c"]
WORKDIR /tmp
ENV RUN_DEPS bash dnsutils coreutils findutils grep ca-certificates libevent-2.1 libssl1.1 expat
RUN apt-get update && \
    apt-get install -qy --no-install-recommends $RUN_DEPS && \
    rm -fr /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/* /var/log/apt/* /var/log/*.log
RUN update-ca-certificates 2> /dev/null || true

COPY --from=encrypted-dns-build /usr/local/cargo/bin/encrypted-dns /opt/encrypted-dns/sbin/encrypted-dns
ENV PATH="/opt/encrypted-dns/sbin/:${PATH}"

RUN mkdir -p /opt/encrypted-dns/empty && \
    groupadd _encrypted-dns && \
    useradd -g _encrypted-dns -s /etc -d /opt/encrypted-dns/empty _encrypted-dns && \
    mkdir -m 700 -p /opt/encrypted-dns/etc/keys && \
    mkdir -m 700 -p /opt/encrypted-dns/etc/lists && \
    chown _encrypted-dns:_encrypted-dns /opt/encrypted-dns/etc/keys && \
    mkdir -m 700 -p /opt/dnscrypt-wrapper/etc/keys && \
    mkdir -m 700 -p /opt/dnscrypt-wrapper/etc/lists && \
    chown _encrypted-dns:_encrypted-dns /opt/dnscrypt-wrapper/etc/keys

COPY encrypted-dns.toml.in /opt/encrypted-dns/etc/
COPY undelegated.txt /opt/encrypted-dns/etc/
COPY entrypoint.sh /

VOLUME ["/opt/encrypted-dns/etc/keys"]

EXPOSE 443/udp 443/tcp 9100/tcp

RUN /opt/encrypted-dns/sbin/encrypted-dns --version

CMD ["/entrypoint.sh", "start"]

ENTRYPOINT ["/entrypoint.sh"]
