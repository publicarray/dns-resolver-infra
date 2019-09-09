FROM alpine:3.10 as unbound-build
ENV REVISION 2

ENV UNBOUND_BUILD_DEPS expat-dev file gcc libevent-dev openssl-dev make musl-dev

RUN apk --no-cache add $UNBOUND_BUILD_DEPS

ARG UNBOUND_VERSION=1.9.3
ARG UNBOUND_SHA256=1b55dd9170e4bfb327fb644de7bbf7f0541701149dff3adf1b63ffa785f16dfa
ARG UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O unbound.tar.gz $UNBOUND_DOWNLOAD_URL && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    ./configure --with-conf-file=/etc/unbound/unbound.conf --with-run-dir=/etc/unbound \
    --with-pthreads --with-username=_unbound --with-libevent \
    CFLAGS="-O2 -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" && \
    make install && \
    ls /usr/local/lib/

#------------------------------------------------------------------------------#
FROM alpine:3.10

ENV UNBOUND_RUN_DEPS expat libevent openssl runit shadow drill wget bc

# https://github.com/NLnetLabs/unbound/blob/master/configure#L2789
ARG LIBUNBOUND_CURRENT=8
# {LIBUNBOUND_CURRENT}.{LIBUNBOUND_AGE}.{LIBUNBOUND_REVISION}
ARG LIBUNBOUND_VERSION=${LIBUNBOUND_CURRENT}.1.3

RUN apk add --no-cache $UNBOUND_RUN_DEPS

COPY --from=0 /usr/local/sbin/unbound /usr/local/sbin/unbound
COPY --from=0 /usr/local/sbin/unbound-checkconf /usr/local/sbin/unbound-checkconf
COPY --from=0 /usr/local/sbin/unbound-control /usr/local/sbin/unbound-control
COPY --from=0 /usr/local/sbin/unbound-host /usr/local/sbin/unbound-host
COPY --from=0 /usr/local/sbin/unbound-anchor /usr/local/sbin/unbound-anchor
COPY --from=0 /usr/local/sbin/unbound-control-setup /usr/local/sbin/unbound-control-setup
COPY --from=0 /usr/local/lib/libunbound.so.${LIBUNBOUND_VERSION} /usr/local/lib/libunbound.so.${LIBUNBOUND_VERSION}

RUN set -x && \
    cd /usr/local/lib/ && \
    ln -sf libunbound.so.${LIBUNBOUND_VERSION} libunbound.so.${LIBUNBOUND_CURRENT} && \
    ln -sf libunbound.so.${LIBUNBOUND_VERSION} libunbound.so && \
    cd && \
    groupadd _unbound && \
    useradd -g _unbound -s /dev/null -d /dev/null _unbound && \
    mkdir -p /etc/service/unbound /etc/unbound/run && \
    unbound-anchor -a /etc/unbound/run/root.key || true && \
    chown _unbound:_unbound /etc/unbound/run && \
    chown _unbound:_unbound /etc/unbound/run/root.key && \
    wget -O /etc/unbound/root.hints https://www.internic.net/domain/named.root \
    update-ca-certificates 2> /dev/null || true

COPY unbound.conf /etc/unbound/unbound.conf
COPY unbound.sh /etc/service/unbound/run
COPY entrypoint.sh /

EXPOSE 53/udp 53/tcp
EXPOSE 4949/tcp
EXPOSE 853/tcp

RUN unbound -h || true
RUN unbound-checkconf /etc/unbound/unbound.conf || true

HEALTHCHECK --start-period=1m --interval=2m \
CMD ["drill", "-D", "-Q", ".", "@127.0.0.1", "SOA"]

ENTRYPOINT ["/entrypoint.sh"]

# Metadata
LABEL org.opencontainers.image.title="unbound" \
        org.opencontainers.image.description="Unbound is a validating, recursive, caching DNS resolver." \
        org.opencontainers.image.url="https://nlnetlabs.nl/projects/unbound/about/" \
        org.opencontainers.image.documentation="https://nlnetlabs.nl/documentation/unbound/" \
        org.opencontainers.image.source="https://nlnetlabs.nl/svn/unbound/" \
        org.opencontainers.image.authors="publicarray" \
        org.opencontainers.image.version=${UNBOUND_VERSION}
