# syntax=docker/dockerfile:1
# hadolint global ignore=DL3007,DL3018
FROM alpine:latest AS image
RUN apk add --no-cache coreutils docker-cli-compose yq tini && truncate -s 0 /etc/crontabs/root
COPY ./entrypoint.sh /entrypoint.sh
WORKDIR /app
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
