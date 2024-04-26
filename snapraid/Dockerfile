# syntax=docker/dockerfile:1.7.1
# hadolint global ignore=DL3007,DL3018
FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.4.0 AS xx

# =========================================================
FROM --platform=$BUILDPLATFORM alpine:3.19.1 AS build
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
RUN apk add --no-cache clang make
COPY --from=xx / /
WORKDIR /src
ARG VERSION
RUN \
url="https://github.com/amadvance/snapraid/releases/download/v${VERSION}/snapraid-${VERSION}.tar.gz"; \
wget -qO- "$url" | tar xz --strip-components=1
ARG TARGETPLATFORM
RUN \
xx-apk add xx-c-essentials; \
CC=xx-clang LDFLAGS=-static ./configure --host "$(xx-clang --print-target-triple)"; \
make; \
xx-verify --static snapraid; \
./snapraid --version

# =========================================================
FROM scratch AS image
ARG VERSION
LABEL org.opencontainers.image.title="snapraid"
LABEL org.opencontainers.image.description="SnapRAID is a backup program for disk arrays. It stores parity information of your data and it recovers from up to six disk failures."
LABEL org.opencontainers.image.url="https://www.snapraid.it"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.source="https://gitlab.com/sprat/snapraid"
LABEL org.opencontainers.image.authors="Sylvain Prat <sylvain.prat@gmail.com>"
COPY --from=build /src/snapraid /bin/
ENTRYPOINT ["/bin/snapraid"]
