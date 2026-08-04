FROM alpine:3.23 AS build
LABEL org.opencontainers.image.source="https://github.com/publicarray/dns-resolver-infra"
ENV REVISION=9
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

ENV UNBOUND_BUILD_DEPS="expat-dev file gcc libevent-dev openssl-dev make musl-dev nghttp2-dev pkgconf"

RUN apk --no-cache add $UNBOUND_BUILD_DEPS

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

ARG NGTCP2_VERSION=1.23.0
ARG NGTCP2_SHA256=364d539c064d37ce0d9a595785d36eecb09926ec308813a6b6550c8adf4a50a4
ARG NGTCP2_DOWNLOAD_URL=https://github.com/ngtcp2/ngtcp2/releases/download/v${NGTCP2_VERSION}/ngtcp2-${NGTCP2_VERSION}.tar.gz

RUN set -x && \
    . /tmp/flags.sh && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -q -O ngtcp2.tar.gz $NGTCP2_DOWNLOAD_URL && \
    echo "${NGTCP2_SHA256} *ngtcp2.tar.gz" | sha256sum -c - && \
    tar xzf ngtcp2.tar.gz && \
    rm -f ngtcp2.tar.gz && \
    cd ngtcp2-${NGTCP2_VERSION} && \
    ./configure --prefix=/usr --enable-lib-only --with-openssl --without-gnutls && \
    make -j"$(nproc)" install

ARG UNBOUND_VERSION=1.26.0
ARG UNBOUND_SHA256=77458a7156e275c0b7b17fabcb357cb12445d95cfcb26fb9bb7d5ecba45e0b63
ARG UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz

RUN set -x && \
    . /tmp/flags.sh && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -q -O unbound.tar.gz $UNBOUND_DOWNLOAD_URL && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    ./configure --with-conf-file=/etc/unbound/unbound.conf --with-run-dir=/etc/unbound \
    --with-pthreads --with-username=_unbound --with-libevent --with-libnghttp2 \
    --with-libngtcp2 && \
    make -j"$(nproc)" install && \
    ls /usr/local/lib/

#------------------------------------------------------------------------------#
FROM alpine:3.23
LABEL org.opencontainers.image.source="https://github.com/publicarray/dns-resolver-infra"

# NB: no apk 'ngtcp2' (that's the GnuTLS build); the OpenSSL-backed libs are copied from the build stage below
ENV UNBOUND_RUN_DEPS="expat libevent openssl runit shadow drill wget bc ca-certificates nghttp2-libs"

# https://github.com/NLnetLabs/unbound/blob/master/configure#L2852
# https://archlinux.pkgs.org/rolling/archlinux-extra-x86_64/unbound-1.25.1-1-x86_64.pkg.tar.zst.html

ARG UNBOUND_VERSION=1.26.0
ARG LIBUNBOUND_SONAME=8
ARG LIBUNBOUND_AGE=1
ARG LIBUNBOUND_REVISION=39

# libtool: shared object name (SONAME) = configure.ac's LIBUNBOUND_CURRENT - LIBUNBOUND_AGE
ARG LIBUNBOUND_VERSION=${LIBUNBOUND_SONAME}.${LIBUNBOUND_AGE}.${LIBUNBOUND_REVISION}

RUN apk add --no-cache $UNBOUND_RUN_DEPS

COPY --from=build /usr/local/sbin/unbound /usr/local/sbin/unbound
COPY --from=build /usr/local/sbin/unbound-checkconf /usr/local/sbin/unbound-checkconf
COPY --from=build /usr/local/sbin/unbound-control /usr/local/sbin/unbound-control
COPY --from=build /usr/local/sbin/unbound-host /usr/local/sbin/unbound-host
COPY --from=build /usr/local/sbin/unbound-anchor /usr/local/sbin/unbound-anchor
COPY --from=build /usr/local/sbin/unbound-control-setup /usr/local/sbin/unbound-control-setup
COPY --from=build /usr/local/lib/libunbound.so.${LIBUNBOUND_VERSION} /usr/local/lib/libunbound.so.${LIBUNBOUND_VERSION}
# ngtcp2 + OpenSSL crypto backend for DNS-over-QUIC (built from source above)
COPY --from=build /usr/lib/libngtcp2.so* /usr/lib/
COPY --from=build /usr/lib/libngtcp2_crypto_ossl.so* /usr/lib/

RUN set -x && \
    cd /usr/local/lib/ && \
    ln -sf libunbound.so.${LIBUNBOUND_VERSION} libunbound.so.${LIBUNBOUND_SONAME} && \
    ln -sf libunbound.so.${LIBUNBOUND_VERSION} libunbound.so && \
    cd && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /dev/null _unbound && \
    mkdir -p /etc/service/unbound /etc/unbound/run && \
    unbound-anchor -a /etc/unbound/run/root.key || true && \
    chown _unbound:_unbound /etc/unbound/run && \
    chown _unbound:_unbound /etc/unbound/run/root.key && \
    wget -q -O /etc/unbound/root.hints https://www.internic.net/domain/named.root && \
    wget -q -O /etc/unbound/run/root.zone https://www.internic.net/domain/root.zone && \
    chown _unbound:_unbound /etc/unbound/run/root.zone && \
    update-ca-certificates 2> /dev/null || true

COPY unbound.conf /etc/unbound/unbound.conf
COPY unbound.sh /etc/service/unbound/run
COPY entrypoint.sh /

EXPOSE 53/udp 53/tcp
EXPOSE 4949/tcp
EXPOSE 853/tcp

RUN unbound -h || true
RUN unbound-control-setup && \
    unbound-checkconf /etc/unbound/unbound.conf && \
    rm -f /etc/unbound/unbound_server.pem /etc/unbound/unbound_server.key \
          /etc/unbound/unbound_control.pem /etc/unbound/unbound_control.key

HEALTHCHECK --start-period=1m --interval=2m CMD ["drill", "-D", "-Q", ".", "@127.0.0.1", "SOA"]

ENTRYPOINT ["/entrypoint.sh"]

LABEL org.opencontainers.image.title="unbound" \
        org.opencontainers.image.description="Unbound is a validating, recursive, caching DNS resolver." \
        org.opencontainers.image.url="https://nlnetlabs.nl/projects/unbound/about/" \
        org.opencontainers.image.documentation="https://nlnetlabs.nl/documentation/unbound/" \
        org.opencontainers.image.source="https://nlnetlabs.nl/svn/unbound/" \
        org.opencontainers.image.authors="publicarray" \
        org.opencontainers.image.version=${UNBOUND_VERSION}
