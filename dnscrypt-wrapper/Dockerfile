FROM alpine:latest
LABEL maintainer "publicarray"
LABEL description ""
ENV REVISION 0

ENV DNSCRYPT_BUILD_DEPS autoconf bsd-compat-headers file libevent-dev make gcc git musl-dev tar wget

RUN apk add --no-cache $DNSCRYPT_BUILD_DEPS

ARG LIBSODIUM_VERSION=1.0.16
ARG LIBSODIUM_SHA256=eeadc7e1e1bcef09680fb4837d448fbdf57224978f865ac1c16745868fbd0533
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
ARG DNSCRYPT_WRAPPER_GIT_BRANCH=master

RUN set -x && \
    cd /tmp/src && \
    git clone --branch=${DNSCRYPT_WRAPPER_GIT_BRANCH} ${DNSCRYPT_WRAPPER_GIT_URL} && \
    cd dnscrypt-wrapper && \
    make configure && \
    ./configure CFLAGS="-Ofast -flto -fPIE -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security" \
    LDFLAGS="-Wl,-z,now -Wl,-z,relro" && \
    make install

#------------------------------------------------------------------------------#
FROM alpine:latest
ENV DNSCYPT_RUN_DEPS libevent runit shadow findutils drill
RUN apk add --no-cache $DNSCYPT_RUN_DEPS

COPY --from=0 /usr/local/sbin/dnscrypt-wrapper /usr/local/sbin/dnscrypt-wrapper
COPY --from=0 /usr/local/lib/libsodium.a /usr/local/lib/libsodium.a
COPY --from=0 /usr/local/lib/libsodium.la /usr/local/lib/libsodium.la
COPY --from=0 /usr/local/lib/libsodium.so.23.1.0 /usr/local/lib/libsodium.so.23.1.0

RUN set -x && \
    cd /usr/local/lib/ && \
    ln -sf libsodium.so.23.1.0 libsodium.so.23 && \
    ln -sf libsodium.so.23.1.0 libsodium.so && \
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

COPY dnscrypt-auto.sh /usr/local/sbin/dnscript-auto
COPY entrypoint.sh /

COPY dnscrypt-wrapper.sh /etc/service/dnscrypt-wrapper/run
COPY key-rotation.sh /etc/service/key-rotation/run
COPY watchdog.sh /etc/service/watchdog/run

VOLUME ["/opt/dnscrypt"]

EXPOSE 443/udp 443/tcp

RUN dnscrypt-wrapper -v

CMD ["/sbin/runsvdir", "-P", "/etc/service"]

ENTRYPOINT ["/entrypoint.sh"]
