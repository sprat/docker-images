# syntax=docker/dockerfile:1.6.0
FROM hadolint/hadolint:2.12.0-alpine AS hadolint
WORKDIR /src
RUN --mount=target=/src \
hadolint --version && \
find . -name Dockerfile -exec hadolint {} +

# =========================================================
FROM koalaman/shellcheck-alpine:v0.9.0 AS shellcheck
SHELL ["/bin/sh", "-euo", "pipefail", "-c"]
WORKDIR /src
RUN --mount=target=/src \
shellcheck --version && \
find /src -name .git -prune -o -type f -executable -print | xargs -r grep -rlE '^#!/bin/(ba)?sh' | xargs -r shellcheck

# =========================================================
FROM pipelinecomponents/yamllint:0.29.0 AS yamllint
WORKDIR /src
RUN --mount=target=/src \
yamllint -v && \
yamllint -s -f colored .
