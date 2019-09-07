FROM alpine:3.10
LABEL maintainer "publicarray"
LABEL name "dnscrypt-wrapper"
LABEL description "https://github.com/jedisct1/dnscrypt-wrapper"
ENV REVISION 3

ENV DNSCRYPT_BUILD_DEPS autoconf bsd-compat-headers file libevent-dev libexecinfo make gcc git musl-dev tar wget

RUN apk add --no-cache $DNSCRYPT_BUILD_DEPS

ARG LIBSODIUM_VERSION=1.0.18
ARG LIBSODIUM_SHA256=6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1
ARG LIBSODIUM_DOWNLOAD_URL=https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VERSION}.tar.gz

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget -O libsodium.tar.gz $LIBSODIUM_DOWNLOAD_URL && \
    echo "${LIBSODIUM_SHA256} *libsodium.tar.gz" | sha256sum -c - && \
    tar xzf libsodium.tar.gz && \
    cd libsodium-${LIBSODIUM_VERSION} && \
    ./configure CFLAGS=-Ofast --disable-dependency-tracking && \
    make check && make install && \
    ldconfig /usr/local/lib

ARG DNSCRYPT_WRAPPER_GIT_URL=https://github.com/jedisct1/dnscrypt-wrapper.git
ARG DNSCRYPT_WRAPPER_GIT_BRANCH=xchacha-stamps

RUN set -x && \
    cd /tmp/src && \
    git clone --branch=${DNSCRYPT_WRAPPER_GIT_BRANCH} ${DNSCRYPT_WRAPPER_GIT_URL} && \
    cd dnscrypt-wrapper && \
    make configure && \
    ./configure CFLAGS="-Ofast -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" && \
    make install && \
    ls /usr/local/lib/

#------------------------------------------------------------------------------#
FROM alpine:3.10
ENV DNSCYPT_RUN_DEPS libevent libexecinfo runit shadow findutils drill
RUN apk add --no-cache $DNSCYPT_RUN_DEPS
ARG SODIUM_LIB_VERSION_MAJOR=23
ARG SODIUM_LIB_VERSION=23.3.0

COPY --from=0 /usr/local/sbin/dnscrypt-wrapper /usr/local/sbin/dnscrypt-wrapper
COPY --from=0 /usr/local/lib/libsodium.a /usr/local/lib/libsodium.a
COPY --from=0 /usr/local/lib/libsodium.la /usr/local/lib/libsodium.la
COPY --from=0 /usr/local/lib/libsodium.so.$SODIUM_LIB_VERSION /usr/local/lib/libsodium.so.$SODIUM_LIB_VERSION

RUN set -x && \
    cd /usr/local/lib/ && ls && \
    ln -sf libsodium.so.$SODIUM_LIB_VERSION libsodium.so.$SODIUM_LIB_VERSION_MAJOR && \
    ln -sf libsodium.so.$SODIUM_LIB_VERSION libsodium.so && \
    cd && \
    mkdir -p /opt/dnscrypt/empty \
        /etc/service/watchdog \
        /etc/service/key-rotation \
        /etc/service/dnscrypt-wrapper && \
    groupadd _dnscrypt-wrapper && \
    useradd -g _dnscrypt-wrapper -s /dev/null -d /opt/dnscrypt/empty _dnscrypt-wrapper && \
    groupadd _dnscrypt-signer && \
    useradd -g _dnscrypt-signer -s /dev/null -d /dev/null _dnscrypt-signer && \
    chown -R _dnscrypt-wrapper:_dnscrypt-wrapper /opt/dnscrypt

COPY entrypoint.sh /

COPY dnscrypt-wrapper.sh /etc/service/dnscrypt-wrapper/run
COPY key-rotation.sh /etc/service/key-rotation/run
COPY watchdog.sh /etc/service/watchdog/run

VOLUME ["/opt/dnscrypt"]

EXPOSE 443/udp 443/tcp

RUN dnscrypt-wrapper -v

CMD ["/sbin/runsvdir", "-P", "/etc/service"]

ENTRYPOINT ["/entrypoint.sh"]
