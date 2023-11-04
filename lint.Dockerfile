# syntax=docker/dockerfile:1
FROM hadolint/hadolint:latest-alpine AS hadolint
WORKDIR /src
RUN --mount=target=/src \
hadolint --version && \
find . -name Dockerfile -exec hadolint {} +

# =========================================================
FROM koalaman/shellcheck-alpine:stable AS shellcheck
SHELL ["/bin/sh", "-euo", "pipefail", "-c"]
WORKDIR /src
RUN --mount=target=/src \
shellcheck --version && \
find /src -name .git -prune -o -type f -executable -print | xargs -r grep -rlE '^#!/bin/(ba)?sh' | xargs -r shellcheck

# =========================================================
FROM cytopia/yamllint:alpine AS yamllint
WORKDIR /src
RUN --mount=target=/src \
yamllint -v && \
yamllint -s -f colored .
