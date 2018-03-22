FROM alpine:latest
MAINTAINER publicarray
ENV REVISION 0

ENV DOH_BUILD_DEPS rust cargo

RUN apk add --no-cache $DOH_BUILD_DEPS
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN cargo install doh-proxy --root /usr/local/

#------------------------------------------------------------------------------#
FROM alpine:latest

ENV DOH_RUN_DEPS libgcc runit shadow

RUN apk add --no-cache $DOH_RUN_DEPS

COPY --from=0 /usr/local/bin/doh-proxy /usr/local/bin/doh-proxy

RUN set -x && \
    groupadd _doh_proxy && \
    useradd -g _doh_proxy -s /dev/null -d /dev/null _doh_proxy && \
    mkdir -p /etc/service/doh-proxy

COPY entrypoint.sh /

EXPOSE 3000/udp 3000/tcp

RUN doh-proxy --version

ENTRYPOINT ["/entrypoint.sh"]
