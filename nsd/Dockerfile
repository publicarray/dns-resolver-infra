FROM alpine:3.22 as build
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
LABEL maintainer="publicarray"
LABEL description="NSD is an authoritative only, high performance, simple and open source name server. https://www.nlnetlabs.nl/projects/nsd/"
ENV REVISION 2

ENV NSD_BUILD_DEPS make tar gcc musl-dev libevent-dev openssl-dev

RUN apk add --no-cache $NSD_BUILD_DEPS

ARG NSD_VERSION=4.13.0
ARG NSD_SHA256=83181b9cfee9495076f124926b28259e7f3911c4da80e17883c211c7e17cd04e
ARG NSD_DOWNLOAD_URL=https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O nsd.tar.gz $NSD_DOWNLOAD_URL && \
    echo "${NSD_SHA256} *nsd.tar.gz" | sha256sum -c - && \
    tar xzf nsd.tar.gz && \
    rm -f nsd.tar.gz && \
    cd nsd-${NSD_VERSION} && \
    ./configure --enable-root-server --with-configdir=/etc/nsd \
    --with-user=_nsd --with-libevent \
    CFLAGS="-O2 -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" && \
    make install

#------------------------------------------------------------------------------#
FROM alpine:3.22
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra

ENV NSD_RUN_DEPS openssl libevent shadow drill
RUN apk add --no-cache $NSD_RUN_DEPS

COPY --from=build /usr/local/sbin/nsd /usr/local/sbin/nsd
COPY --from=build /usr/local/sbin/nsd-control-setup /usr/local/sbin/nsd-control-setup
COPY --from=build /usr/local/sbin/nsd-checkconf /usr/local/sbin/nsd-checkconf
COPY --from=build /usr/local/sbin/nsd-checkzone /usr/local/sbin/nsd-checkzone
COPY --from=build /usr/local/sbin/nsd-control /usr/local/sbin/nsd-control

RUN set -x && \
    groupadd _nsd && \
    useradd -g _nsd -s /dev/null -d /dev/null _nsd && \
    mkdir -p /etc/nsd/run/zonefiles /etc/service/nsd && \
    chown _nsd:_nsd /etc/nsd/run/zonefiles && \
    chown _nsd:_nsd /etc/nsd/run

COPY nsd.conf /etc/nsd/nsd.conf
COPY opennic.conf /etc/nsd/opennic.conf
COPY entrypoint.sh /

VOLUME ["/etc/nsd/run"]

EXPOSE 53/udp 53/tcp

RUN nsd -v
RUN nsd-checkconf /etc/nsd/nsd.conf

HEALTHCHECK --start-period=5s --interval=2m \
CMD ["drill", "-Q", "dns.opennic.glue", "@127.0.0.1", "SOA"]

CMD ["-d"]

ENTRYPOINT ["/entrypoint.sh"]
