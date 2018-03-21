FROM alpine:latest
MAINTAINER publicarray
ENV REVISION 0

ENV HAPROXY_BUILD_DEPS make tar gcc musl-dev linux-headers openssl-dev

RUN apk add --no-cache $HAPROXY_BUILD_DEPS

# haproxy v 1.8 + is required for http/2
ENV HAPROXY_MAJOR 1.8
ENV HAPROXY_VERSION 1.8.4
RUN export HAPROXY_MAJOR=$(echo ${HAPROXY_VERSION} | awk -F \. '{print $1"."$2}')

ENV HAPROXY_DOWNLOAD_URL "https://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz"
ENV HAPROXY_SHA256 e305b0a4e7dec08072841eef6ac6dcd1b5586b1eff09c2d51e152a912e8884a6

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O haproxy.tar.gz $HAPROXY_DOWNLOAD_URL && \
    echo "${HAPROXY_SHA256} *haproxy.tar.gz" | sha256sum -c - && \
    tar xzf haproxy.tar.gz && \
    rm -f haproxy.tar.gz && \
    cd haproxy-${HAPROXY_VERSION} && \
    make TARGET=linux2628 USE_OPENSSL=1 USE_ZLIB=1 && \
    make install-bin && \
    rm -fr /tmp/* /var/tmp/*

#------------------------------------------------------------------------------#
FROM alpine:latest

ENV HAPROXY_RUN_DEPS openssl shadow

RUN apk add --no-cache $HAPROXY_RUN_DEPS

COPY --from=0 /usr/local/sbin/haproxy /usr/local/sbin/haproxy

RUN set -x && \
    groupadd _haproxy && \
    useradd -g _haproxy -s /dev/null -d /dev/null _haproxy && \
    mkdir -p /etc/service/haproxy

COPY haproxy.conf /etc/haproxy.conf

VOLUME ["/opt/ssl"]

EXPOSE 443/udp 443/tcp

RUN haproxy -v

CMD ["-f /etc/haproxy.conf"]

ENTRYPOINT ["/usr/local/sbin/haproxy"]
