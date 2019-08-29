FROM golang:alpine3.9 as doh-build
LABEL maintainer "publicarray"
LABEL description "High performance DNS over HTTPS server in golang. https://github.com/m13253/dns-over-https"
ENV REVISION 1

ENV DOH_BUILD_DEPS git make
ENV VERSION 2.1.2
ENV COMMIT 9b8fab691c00b9e5380b19ce882f3271

RUN apk add --no-cache $DOH_BUILD_DEPS

RUN set -x && \
    mkdir ~/gopath && \
    export GOPATH=~/gopath && \
    git clone https://github.com/m13253/dns-over-https.git && \
    cd dns-over-https && \
    git checkout ${COMMIT} && \
    make && \
    make install
# git checkout tags/v${VERSION} && \
#------------------------------------------------------------------------------#
FROM alpine:3.9

ENV DOH_RUN_DEPS curl

RUN apk add --no-cache $DOH_RUN_DEPS

COPY --from=0 /usr/local/bin/doh-server /usr/local/bin/doh-server

COPY entrypoint.sh /
COPY doh-server.conf /etc/dns-over-https/doh-server.conf

EXPOSE 3000/udp 3000/tcp

RUN /usr/local/bin/doh-server -version

HEALTHCHECK --start-period=5s --interval=60s \
CMD curl -H 'accept: application/dns-message' 'http://127.0.0.1:3000/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
