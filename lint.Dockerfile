# syntax=docker/dockerfile:1
FROM hadolint/hadolint:latest-alpine AS hadolint
RUN --mount=target=/src \
hadolint --version && \
find . -name Dockerfile -exec hadolint {} +

# =========================================================
FROM koalaman/shellcheck-alpine:stable AS shellcheck
WORKDIR /src
RUN --mount=target=/src \
shellcheck --version && \
find /src -name '*.sh' -exec shellcheck {} +

# =========================================================
FROM cytopia/yamllint:alpine AS yamllint
RUN --mount=type=bind,target=. \
yamllint -v && yamllint -s -f colored .
