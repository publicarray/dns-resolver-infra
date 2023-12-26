FROM rust:latest as doh-proxy-build
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
ENV REVISION 1
ARG VERSION=0.9.9

ENV RUSTFLAGS "-C link-arg=-s"
RUN cargo install doh-proxy --version $VERSION --target=x86_64-unknown-linux-gnu && \
    strip --strip-all /usr/local/cargo/bin/doh-proxy

#------------------------------------------------------------------------------#
FROM ubuntu:22.04
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
LABEL maintainer="publicarray"
LABEL description="A DNS-over-HTTP server proxy in Rust. https://github.com/DNSCrypt/doh-server"

RUN apt-get update && \
    apt-get install -qy --no-install-recommends bash libc6 curl ca-certificates dnsutils libssl3 && \
    rm -fr /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/* /var/log/apt/* /var/log/*.log
RUN update-ca-certificates 2> /dev/null || true
COPY --from=doh-proxy-build /usr/local/cargo/bin/doh-proxy /usr/local/bin/doh-proxy

RUN set -x && \
    groupadd _doh_proxy && \
    useradd -g _doh_proxy -s /dev/null -d /dev/null _doh_proxy

USER _doh_proxy

COPY entrypoint.sh /

EXPOSE 3000/udp 3000/tcp

RUN doh-proxy --version

HEALTHCHECK --start-period=5s --interval=2m \
CMD curl -f -H 'accept: application/dns-message' 'http://127.0.0.1:3000/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
