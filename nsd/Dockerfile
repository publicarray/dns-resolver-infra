FROM alpine:latest
MAINTAINER publicarray
ENV REVISION 0

ENV NSD_BUILD_DEPS  make tar gcc musl-dev libevent-dev openssl-dev

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
ENV NSD_RUN_DEPS  openssl libevent-dev runit shadow

RUN apk add --no-cache $NSD_RUN_DEPS

COPY --from=0 /usr/local/sbin/nsd /usr/local/sbin/nsd
COPY --from=0 /usr/local/sbin/nsd-control-setup /usr/local/sbin/nsd-control-setup
COPY --from=0 /usr/local/sbin/nsd-checkconf /usr/local/sbin/nsd-checkconf
COPY --from=0 /usr/local/sbin/nsd-checkzone /usr/local/sbin/nsd-checkzone
COPY --from=0 /usr/local/sbin/nsd-control /usr/local/sbin/nsd-control

RUN groupadd _nsd && \
    useradd -g _nsd -s /dev/null -d /dev/null _nsd

RUN set -x &&\
    mkdir -p \
    /etc/nsd/run/zonefiles \
    /etc/service/nsd && \
    chown _nsd /etc/nsd/run/zonefiles && \
    chown _nsd /etc/nsd/run/ && \
    nsd-control-setup

COPY nsd.conf /etc/nsd/nsd.conf
COPY opennic.conf /etc/nsd/opennic.conf

COPY nsd.sh /etc/service/nsd/


# ./install-sh -c -d /usr/local/sbin
# ./install-sh -c -d /etc/nsd
# ./install-sh -c -d /var/run
# ./install-sh -c -d /tmp
# ./install-sh -c -d /var/db/nsd
# ./install-sh -c -d /usr/local/share/man
# ./install-sh -c -d /usr/local/share/man/man8
# ./install-sh -c -d /usr/local/share/man/man5
# ./install-sh -c nsd /usr/local/sbin/nsd
# ./install-sh -c nsd-control-setup.sh /usr/local/sbin/nsd-control-setup
# ./install-sh -c nsd-checkconf /usr/local/sbin/nsd-checkconf
# ./install-sh -c nsd-checkzone /usr/local/sbin/nsd-checkzone
# ./install-sh -c nsd-control /usr/local/sbin/nsd-control
# ./install-sh -c -m 644 nsd.8 /usr/local/share/man/man8
# ./install-sh -c -m 644 nsd-checkconf.8 /usr/local/share/man/man8/nsd-checkconf.8
# ./install-sh -c -m 644 nsd-checkzone.8 /usr/local/share/man/man8/nsd-checkzone.8
# ./install-sh -c -m 644 nsd-control.8 /usr/local/share/man/man8/nsd-control.8
# ./install-sh -c -m 644 nsd.conf.5 /usr/local/share/man/man5/nsd.conf.5
# ./install-sh -c -m 644 nsd.conf.sample /etc/nsd/nsd.conf.sample

COPY entrypoint.sh /

EXPOSE 552/udp 552/tcp

RUN nsd -v

CMD ["/sbin/runsvdir -P /etc/service"]

ENTRYPOINT ["/entrypoint.sh"]
