# syntax=docker/dockerfile:1
# hadolint global ignore=DL3007,DL3018
FROM alpine:latest AS image
RUN apk add --no-cache git musl-dev gcc binutils make perl xz-dev mtools syslinux cdrkit
ARG VERSION
RUN git clone --branch "$VERSION" https://github.com/ipxe/ipxe.git /opt/ipxe
COPY rootfs/ /
WORKDIR /out
