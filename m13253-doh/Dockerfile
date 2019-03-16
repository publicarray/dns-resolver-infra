FROM golang:alpine3.9 as doh-build
LABEL maintainer "publicarray"
LABEL description "High performance DNS over HTTPS server in golang. https://github.com/m13253/dns-over-https"
ENV REVISION 1

ENV DOH_BUILD_DEPS git make
ENV VERSION 1.4.2

RUN apk add --no-cache $DOH_BUILD_DEPS

RUN set -x && \
    mkdir ~/gopath && \
    export GOPATH=~/gopath && \
    git clone https://github.com/m13253/dns-over-https.git && \
    cd dns-over-https && \
    git checkout tags/v${VERSION} && \
    make && \
    make install

#------------------------------------------------------------------------------#
FROM alpine:3.9

# ENV DOH_RUN_DEPS libgcc runit shadow curl

# RUN apk add --no-cache $DOH_RUN_DEPS

COPY --from=0 /usr/local/bin/doh-server /usr/local/bin/doh-server

# RUN set -x && \
#     groupadd _doh_server && \
#     useradd -g _doh_server -s /dev/null -d /dev/null _doh_server && \
#     mkdir -p /etc/service/doh-server

COPY entrypoint.sh /
COPY doh-server.conf /etc/dns-over-https/doh-server.conf

EXPOSE 4000/udp 4000/tcp

RUN /usr/local/bin/doh-server -version

HEALTHCHECK --start-period=5s --interval=60s \
CMD curl -H 'accept: application/dns-message' 'http://127.0.0.1:4000/dns-query?dns=q80BAAABAAAAAAAAA3d3dwdleGFtcGxlA2NvbQAAAQAB' >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
