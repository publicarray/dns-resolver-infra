FROM golang:alpine3.17 as doh-build
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra
LABEL maintainer="publicarray"
LABEL description="High performance DNS over HTTPS server in golang. https://github.com/m13253/dns-over-https"
ENV REVISION 2

ENV DOH_BUILD_DEPS git make
ENV COMMIT 244e4b5b8fdb4e7d6758622d445d4533d053f565
RUN apk add --no-cache $DOH_BUILD_DEPS

RUN set -x && \
    mkdir ~/gopath && \
    export GOPATH=~/gopath && \
    git clone https://github.com/m13253/dns-over-https.git && \
    cd dns-over-https && \
    git checkout ${COMMIT} && \
    make && \
    make install
#------------------------------------------------------------------------------#
FROM alpine:3.17
LABEL org.opencontainers.image.source https://github.com/publicarray/dns-resolver-infra

ENV DOH_RUN_DEPS curl bind-tools

RUN apk add --no-cache $DOH_RUN_DEPS

COPY --from=0 /usr/local/bin/doh-server /usr/local/bin/doh-server

COPY entrypoint.sh /
COPY doh-server.conf /etc/dns-over-https/doh-server.conf

EXPOSE 3000/udp 3000/tcp

RUN /usr/local/bin/doh-server -version

HEALTHCHECK --start-period=5s --interval=60s \
CMD curl -H 'accept: application/dns-message' 'http://127.0.0.1:3000/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
