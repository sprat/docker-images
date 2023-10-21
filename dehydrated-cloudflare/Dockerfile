# syntax=docker/dockerfile:1
# hadolint global ignore=DL3007,DL3018
FROM alpine:latest
ARG VERSION
# coreutils sed gawk grep diffutils
RUN apk add --no-cache tini bash openssl curl jq \
&& curl -sSLo /usr/bin/dehydrated https://raw.githubusercontent.com/dehydrated-io/dehydrated/${VERSION}/dehydrated \
&& chmod +x /usr/bin/dehydrated \
&& mkdir -p /etc/dehydrated/config.d
COPY rootfs /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
