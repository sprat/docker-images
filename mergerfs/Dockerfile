# syntax=docker/dockerfile:1
# hadolint global ignore=DL3007
FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.9.0 AS xx

# =========================================================
FROM --platform=$BUILDPLATFORM alpine:3.23.2 AS build
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
COPY --from=xx / /
ARG VERSION
ARG TARGETPLATFORM
RUN \
ARCH=$(xx-info debian-arch); \
URL=https://github.com/trapexit/mergerfs/releases/download/${VERSION}/mergerfs-${VERSION}-static-linux_${ARCH}.tar.gz; \
wget -qO- "$URL" | tar xz; \
xx-verify --static /usr/local/bin/mergerfs*

# =========================================================
FROM scratch AS image
COPY --from=build /usr/local/bin/mergerfs* /usr/bin/
ARG VERSION
LABEL org.opencontainers.image.title="mergerfs"
LABEL org.opencontainers.image.description="A featureful union filesystem"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.url="https://github.com/trapexit/mergerfs"
LABEL org.opencontainers.image.licenses="ISC"
LABEL org.opencontainers.image.source="https://github.com/sprat/docker-images"
LABEL org.opencontainers.image.authors="Sylvain Prat <sylvain.prat@achird.net>"
ENTRYPOINT ["/usr/bin/mergerfs", "-f"]
