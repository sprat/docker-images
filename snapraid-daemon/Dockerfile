# syntax=docker/dockerfile:1
# hadolint global ignore=DL3007,DL3018
FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.9.0 AS xx

# =========================================================
FROM --platform=$BUILDPLATFORM alpine:3.23.3 AS build
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN apk add --no-cache clang make zip
# hadolint ignore=DL3067
COPY --from=xx / /
WORKDIR /src
ARG TARGETPLATFORM
ARG VERSION
RUN \
    url="https://github.com/amadvance/snapraid-daemon/releases/download/v${VERSION}/snapraid-daemon-${VERSION}.tar.gz"; \
    wget -qO- "$url" | tar xz --strip-components=1; \
    xx-apk add --no-cache xx-c-essentials; \
    # The startup probe exceeds musl's default 128 KiB worker-thread stack.
    CC=xx-clang LDFLAGS="-static -Wl,-z,stack-size=1048576" ./configure --host "$(xx-clang --print-target-triple)"; \
    make; \
    xx-verify --static snapraidd; \
    ./snapraidd --version
WORKDIR /rootfs
RUN \
    mkdir -p etc run usr/bin usr/share/snapraidd var/log/snapraid; \
    printf 'nobody:x:65534:65534:nobody:/:/sbin/nologin\n' > etc/passwd; \
    printf 'nobody:x:65534:\n' > etc/group; \
    mv /src/commander.zip usr/share/snapraidd/commander.zip; \
    mv /src/snapraidd usr/bin/snapraidd;

# =========================================================
FROM scratch AS image
COPY --from=build /rootfs/ /
ARG VERSION
LABEL org.opencontainers.image.title="snapraid-daemon"
LABEL org.opencontainers.image.description="snapraid-daemon is a specialized companion service designed to move SnapRAID from a manual, command-line interface (CLI) workflow to an 'always-on' background service."
LABEL org.opencontainers.image.url="https://www.snapraid.it"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.source="https://github.com/sprat/docker-images"
LABEL org.opencontainers.image.authors="Sylvain Prat <sylvain.prat@achird.net>"
ENTRYPOINT ["/usr/bin/snapraidd"]
CMD ["-f"]
