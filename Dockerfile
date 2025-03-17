# syntax=docker/dockerfile:1
FROM hadolint/hadolint:2.12.0-alpine AS hadolint
WORKDIR /src
RUN --mount=target=. \
hadolint --version && \
find . -name Dockerfile -exec hadolint {} +

# =========================================================
FROM koalaman/shellcheck-alpine:v0.10.0 AS shellcheck
SHELL ["/bin/ash", "-euo", "pipefail", "-c"]
WORKDIR /src
RUN --mount=target=. \
shellcheck --version && \
find . -name .git -prune -o -type f -executable -print0 | xargs -r0 grep -rlE '^#!/bin/(ba)?sh' | xargs -r shellcheck

# =========================================================
FROM toolhippie/yamllint:1.36.2 AS yamllint
WORKDIR /src
RUN --mount=target=. \
yamllint -v && \
yamllint -s -f colored .
