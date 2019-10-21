FROM rustlang/rust:nightly-alpine AS doh-proxy-build
ENV REVISION 0
ENV VERSION 0.1.21
SHELL ["/bin/sh", "-x", "-c"]
ENV RUSTFLAGS "-C link-arg=-s"
RUN cargo install doh-proxy --version $VERSION && \
    strip --strip-all /usr/local/cargo/bin/doh-proxy

#------------------------------------------------------------------------------#
FROM alpine:3.10
LABEL maintainer "publicarray"
LABEL description "A DNS-over-HTTP server proxy in Rust. https://github.com/jedisct1/rust-doh"

ENV DOH_RUN_DEPS libgcc runit shadow curl

RUN apk add --no-cache $DOH_RUN_DEPS

COPY --from=doh-proxy-build /usr/local/cargo/bin/doh-proxy /usr/local/bin/doh-proxy

RUN set -x && \
    groupadd _doh_proxy && \
    useradd -g _doh_proxy -s /dev/null -d /dev/null _doh_proxy && \
    mkdir -p /etc/service/doh-proxy

COPY entrypoint.sh /

EXPOSE 3000/udp 3000/tcp

RUN doh-proxy --version

HEALTHCHECK --start-period=5s --interval=2m \
CMD curl -f -H 'accept: application/dns-message' 'http://127.0.0.1:3000/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
