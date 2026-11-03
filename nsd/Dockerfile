FROM alpine:3.24 AS build
LABEL org.opencontainers.image.source="https://github.com/publicarray/dns-resolver-infra"
LABEL maintainer="publicarray"
LABEL description="NSD is an authoritative only, high performance, simple and open source name server. https://www.nlnetlabs.nl/projects/nsd/"
ENV REVISION=2
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

ENV NSD_BUILD_DEPS="make tar gcc musl-dev libevent-dev openssl-dev protobuf-c-dev fstrm-dev"

RUN apk add --no-cache $NSD_BUILD_DEPS

ARG TARGETARCH
RUN set -x && \
    case "$TARGETARCH" in \
      amd64) ARCH_CFLAGS="-march=x86-64-v3 -fcf-protection=full" ;; \
      arm64) ARCH_CFLAGS="-mbranch-protection=standard" ;; \
      *)     ARCH_CFLAGS="" ;; \
    esac && \
    { \
      echo "export CFLAGS=\"-O2 -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security -fstack-clash-protection ${ARCH_CFLAGS}\""; \
      echo "export LDFLAGS=\"-pie -flto -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack\""; \
    } > /tmp/flags.sh

ARG NSD_VERSION=4.15.4
ARG NSD_SHA256=74a095fdb774a157c8aec9009e440fc3d2ba94c4372ae9ed86588c1719d1df2f
ARG NSD_DOWNLOAD_URL=https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz

RUN set -x && \
    . /tmp/flags.sh && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -q -O nsd.tar.gz $NSD_DOWNLOAD_URL && \
    echo "${NSD_SHA256} *nsd.tar.gz" | sha256sum -c - && \
    tar xzf nsd.tar.gz && \
    rm -f nsd.tar.gz && \
    cd nsd-${NSD_VERSION} && \
    ./configure --enable-root-server --with-configdir=/etc/nsd \
    --with-user=_nsd --with-libevent && \
    make -j"$(nproc)" install

#------------------------------------------------------------------------------#
FROM alpine:3.24
LABEL org.opencontainers.image.source="https://github.com/publicarray/dns-resolver-infra"

ENV NSD_RUN_DEPS="openssl libevent shadow drill protobuf-c fstrm"
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

RUN nsd -v && \
    nsd-checkconf /etc/nsd/nsd.conf

HEALTHCHECK --start-period=5s --interval=2m CMD ["drill", "-Q", "dns.opennic.glue", "@127.0.0.1", "SOA"]

CMD ["-d"]

ENTRYPOINT ["/entrypoint.sh"]
