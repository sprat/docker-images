# syntax=docker/dockerfile:1.6.0
# hadolint global ignore=DL3007
FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.3.0 AS xx

# =========================================================
FROM --platform=$BUILDPLATFORM alpine:3.19.1 AS build
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
COPY --from=xx / /
ARG VERSION
ARG TARGETPLATFORM
RUN \
ARCH=$(xx-info debian-arch); \
URL=https://github.com/trapexit/mergerfs/releases/download/${VERSION}/mergerfs-static-linux_${ARCH}.tar.gz; \
wget -qO- "$URL" | tar xz; \
xx-verify --static /usr/local/bin/mergerfs*

# =========================================================
FROM scratch AS image
COPY --from=build /usr/local/bin/mergerfs* /bin/
ARG VERSION
LABEL org.opencontainers.image.title="mergerfs"
LABEL org.opencontainers.image.description="A featureful union filesystem"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.url="https://github.com/trapexit/mergerfs"
LABEL org.opencontainers.image.licenses="ISC"
LABEL org.opencontainers.image.source="https://gitlab.com/sprat/mergerfs"
LABEL org.opencontainers.image.authors="Sylvain Prat <sylvain.prat@gmail.com>"
ENTRYPOINT ["/bin/mergerfs", "-f"]
