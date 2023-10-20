FROM hadolint/hadolint:latest-alpine AS hadolint
RUN --mount=target=/src \
hadolint --version && \
find . -name Dockerfile | xargs -r hadolint
