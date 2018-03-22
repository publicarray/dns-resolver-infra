FROM alpine:latest
MAINTAINER publicarray
ENV REVISION 0

ENV NSD_BUILD_DEPS make tar gcc musl-dev libevent-dev libressl-dev

RUN apk add --no-cache $NSD_BUILD_DEPS

ENV NSD_VERSION 4.1.20
ENV NSD_SHA256 8a97f61d7bbb98a2ce04dc4425596f9023677a5f1c5ea743ff408d487f82f713
ENV NSD_DOWNLOAD_URL https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O nsd.tar.gz $NSD_DOWNLOAD_URL && \
    echo "${NSD_SHA256} *nsd.tar.gz" | sha256sum -c - && \
    tar xzf nsd.tar.gz && \
    rm -f nsd.tar.gz && \
    cd nsd-${NSD_VERSION} && \
    ./configure --enable-root-server --with-configdir=/etc/nsd \
    --with-user=_nsd --with-libevent && \
    make install

#------------------------------------------------------------------------------#
FROM alpine:latest

ENV NSD_RUN_DEPS libressl libevent shadow

RUN apk add --no-cache $NSD_RUN_DEPS

COPY --from=0 /usr/local/sbin/nsd /usr/local/sbin/nsd
COPY --from=0 /usr/local/sbin/nsd-control-setup /usr/local/sbin/nsd-control-setup
COPY --from=0 /usr/local/sbin/nsd-checkconf /usr/local/sbin/nsd-checkconf
COPY --from=0 /usr/local/sbin/nsd-checkzone /usr/local/sbin/nsd-checkzone
COPY --from=0 /usr/local/sbin/nsd-control /usr/local/sbin/nsd-control

RUN set -x && \
    groupadd _nsd && \
    useradd -g _nsd -s /dev/null -d /dev/null _nsd && \
    mkdir -p /etc/nsd/run/zonefiles /etc/service/nsd && \
    chown _nsd:_nsd /etc/nsd/run/zonefiles && \
    chown _nsd:_nsd /etc/nsd/run && \
    nsd-control-setup

COPY nsd.conf /etc/nsd/nsd.conf
COPY opennic.conf /etc/nsd/opennic.conf

EXPOSE 53/udp 53/tcp

RUN nsd -v

CMD ["-d"]

ENTRYPOINT ["/usr/local/sbin/nsd"]
