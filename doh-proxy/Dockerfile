FROM rust:latest as doh-proxy-build
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
ENV REVISION 1
ARG VERSION=0.3.3

RUN apt-get update && \
    apt-get install -qy --no-install-recommends musl-tools libssl-dev && \
    rm -fr /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/* /var/log/apt/* /var/log/*.log

RUN rustup target add x86_64-unknown-linux-musl
ENV RUSTFLAGS "-Clinker=musl-gcc -C link-arg=-s"
RUN cargo install doh-proxy --version $VERSION --target=x86_64-unknown-linux-musl && \
    strip --strip-all /usr/local/cargo/bin/doh-proxy

#------------------------------------------------------------------------------#
FROM alpine:3.11
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
LABEL maintainer="publicarray"
LABEL description="A DNS-over-HTTP server proxy in Rust. https://github.com/jedisct1/rust-doh"

RUN apk add --no-cache bash libgcc runit shadow curl openssl bind-tools

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
