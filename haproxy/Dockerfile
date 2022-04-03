FROM alpine:3.15 as build
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
LABEL maintainer="publicarray"
LABEL description="The Reliable, High Performance TCP/HTTP Load Balancer"


ENV HAPROXY_BUILD_DEPS gcc ca-certificates libc-dev linux-headers make openssl-dev pcre2-dev readline-dev tar zlib-dev
RUN apk add --no-cache $HAPROXY_BUILD_DEPS

ENV HAPROXY_VERSION_SHORT 2.5
ENV HAPROXY_VERSION 2.5.5
ENV HAPROXY_SHA256 063c4845cdb2d76f292ef44d9c0117a853d8d10ae5d9615b406b14a4d74fe4b9
ENV HAPROXY_DOWNLOAD_URL "https://www.haproxy.org/download/${HAPROXY_VERSION_SHORT}/src/haproxy-${HAPROXY_VERSION}.tar.gz"

RUN set -x && \
    mkdir -p /tmp/src/haproxy && \
    cd /tmp/src/haproxy && \
    wget -O haproxy.tar.gz $HAPROXY_DOWNLOAD_URL && \
    echo "${HAPROXY_SHA256} *haproxy.tar.gz" | sha256sum -c - && \
    tar xzf haproxy.tar.gz -C /tmp/src/haproxy --strip-components=1 && \
    nproc="$(getconf _NPROCESSORS_ONLN)" && \
    makeOpts=' \
        TARGET=linux-musl \
        USE_GETADDRINFO=1 \
        USE_OPENSSL=1 \
        USE_PCRE2=1 \
        USE_PCRE2_JIT=1 \
        USE_ZLIB=1 \
    ' && \
    eval "make $makeOpts -j '$nproc' all"  && \
    eval "make $makeOpts install-bin"

#------------------------------------------------------------------------------#
FROM alpine:3.15
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra

ENV HAPROXY_RUN_DEPS curl shadow zlib pcre2 openssl socat runit coreutils bind-tools

RUN apk add --no-cache $HAPROXY_RUN_DEPS

COPY --from=build /usr/local/sbin/haproxy /usr/local/sbin/haproxy
COPY --from=build /tmp/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors

RUN set -x && \
    groupadd _haproxy && \
    useradd -g _haproxy -s /dev/null -d /dev/null _haproxy && \
    mkdir -p \
        /etc/service/haproxy/ \
        /run/haproxy/ \
        /etc/service/ocsp-updater && \
    update-ca-certificates 2> /dev/null || true

COPY entrypoint.sh /
COPY haproxy.conf /etc/haproxy.conf
COPY haproxy.sh /etc/service/haproxy/run
COPY ocsp-updater.sh /etc/service/ocsp-updater/run
# wget https://ssl-config.mozilla.org/ffdhe2048.txt -O /opt/ssl/dhparam.pem
COPY ffdhe2048.txt /opt/ssl/dhparam.pem

VOLUME ["/opt/ssl"]

EXPOSE 853/udp 853/tcp 443/udp 443/tcp

RUN haproxy -vv
RUN haproxy -f /etc/haproxy.conf -c || true

# Gracefully exit
# All services are then put into soft-stop state,
# which means that they will refuse to accept new connections
STOPSIGNAL SIGUSR1

# HEALTHCHECK --start-period=5s --interval=3m \
# CMD curl -f -H 'accept: application/dns-message' -k 'https://127.0.0.1/dns-query?ct&dns=AAABAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB'>/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
