FROM alpine:3.9
LABEL maintainer "publicarray"
LABEL description "The Reliable, High Performance TCP/HTTP Load Balancer"
ENV REVISION 2

ENV HAPROXY_BUILD_DEPS gcc linux-headers make openssl-dev musl-dev pcre-dev tar zlib-dev

RUN apk add --no-cache $HAPROXY_BUILD_DEPS

# haproxy v 1.8 + is required for http/2
# https://www.haproxy.org/download/1.8/src/CHANGELOG
ENV HAPROXY_MAJOR 1.9
ENV HAPROXY_VERSION 1.9.5
ENV HAPROXY_SHA256 407260ce65d7a16d93a037976712a8742985ce29360b6d5c187a849b6c0fbf8c
RUN export HAPROXY_MAJOR=$(echo ${HAPROXY_VERSION} | awk -F \. '{print $1"."$2}')
ENV HAPROXY_DOWNLOAD_URL "https://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz"

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O haproxy.tar.gz $HAPROXY_DOWNLOAD_URL && \
    echo "${HAPROXY_SHA256} *haproxy.tar.gz" | sha256sum -c - && \
    tar xzf haproxy.tar.gz && \
    cd haproxy-${HAPROXY_VERSION} && \
    make TARGET=linux2628 USE_OPENSSL=1 USE_STATIC_PCRE=1 USE_PCRE_JIT=1 USE_ZLIB=1 && \
    make install-bin

#------------------------------------------------------------------------------#
FROM alpine:3.9

ENV HAPROXY_RUN_DEPS curl shadow zlib openssl socat runit

RUN apk add --no-cache $HAPROXY_RUN_DEPS

COPY --from=0 /usr/local/sbin/haproxy /usr/local/sbin/haproxy

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

VOLUME ["/opt/ssl"]

EXPOSE 853/udp 853/tcp 443/udp 443/tcp

RUN haproxy -v

# HEALTHCHECK --start-period=5s --interval=60s \
# CMD curl -H 'Content-Type: application/dns-udpwireformat' -f 'https://127.0.0.1/dns-query?ct&dns=AAABAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB'>/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
