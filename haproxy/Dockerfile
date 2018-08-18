FROM alpine:3.8
LABEL maintainer "publicarray"
LABEL description "The Reliable, High Performance TCP/HTTP Load Balancer"
ENV REVISION 1

ENV OPENSSL_BUILD_DEPS perl zlib-dev
ENV HAPROXY_BUILD_DEPS gcc linux-headers make musl-dev pcre-dev tar zlib-dev

RUN apk add --no-cache $HAPROXY_BUILD_DEPS $OPENSSL_BUILD_DEPS

ENV OPENSSL_VERSION 1.1.1-pre8
ENV OPENSSL_SHA256 1205cd763dd92c910cc590658a5b0774599e8587d89d6debd948f242b949321e

# https://git.alpinelinux.org/cgit/aports/tree/testing/openssl1.1/APKBUILD
RUN set -x && \
    mkdir -p /tmp/src /tmp/openssl && \
    cd /tmp/src && \
    wget -O openssl.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    echo "${OPENSSL_SHA256} *openssl.tar.gz" | sha256sum -c - && \
    tar xzf openssl.tar.gz && \
    cd openssl-${OPENSSL_VERSION} && \
    ./config no-shared zlib -DOPENSSL_NO_ASYNC --prefix=/tmp/openssl && \
    make && \
    make test && \
    make install_sw

# haproxy v 1.8 + is required for http/2
# https://www.haproxy.org/download/1.8/src/CHANGELOG
ENV HAPROXY_MAJOR 1.8
ENV HAPROXY_VERSION 1.8.13
RUN export HAPROXY_MAJOR=$(echo ${HAPROXY_VERSION} | awk -F \. '{print $1"."$2}')

ENV HAPROXY_DOWNLOAD_URL "https://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz"
ENV HAPROXY_SHA256 bcc05ab824bd2f89b8b21ac05459c0a0a0e02247b57ffe441d52cfe771daea92

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O haproxy.tar.gz $HAPROXY_DOWNLOAD_URL && \
    echo "${HAPROXY_SHA256} *haproxy.tar.gz" | sha256sum -c - && \
    tar xzf haproxy.tar.gz && \
    cd haproxy-${HAPROXY_VERSION} && \
    make TARGET=linux2628 USE_OPENSSL=1 SSL_INC=/tmp/openssl/include SSL_LIB=/tmp/openssl/lib USE_STATIC_PCRE=1 USE_PCRE_JIT=1 USE_ZLIB=1 && \
    make install-bin

#------------------------------------------------------------------------------#
FROM alpine:3.8

ENV HAPROXY_RUN_DEPS curl shadow zlib

RUN apk add --no-cache $HAPROXY_RUN_DEPS

COPY --from=0 /usr/local/sbin/haproxy /usr/local/sbin/haproxy
# COPY --from=0 /usr/local/lib/libcrypto.a /usr/local/lib/libcrypto.a
# COPY --from=0 /usr/local/lib/libssl.a /usr/local/lib/libssl.a
# COPY --from=0 /usr/local/bin/openssl /usr/local/bin/openssl
# COPY --from=0 /usr/local/bin/c_rehash /usr/local/bin/c_rehash

RUN set -x && \
    groupadd _haproxy && \
    useradd -g _haproxy -s /dev/null -d /dev/null _haproxy && \
    mkdir -p /etc/service/haproxy

COPY entrypoint.sh /
COPY haproxy.conf /etc/haproxy.conf

VOLUME ["/opt/ssl"]

EXPOSE 853/udp 853/tcp 443/udp 443/tcp

RUN haproxy -v

# HEALTHCHECK --start-period=5s --interval=60s \
# CMD curl -H 'Content-Type: application/dns-udpwireformat' -f 'https://127.0.0.1/dns-query?ct&dns=AAABAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB'>/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
