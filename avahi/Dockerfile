FROM alpine:3.20.2
# hadolint global ignore=DL3018
RUN apk add --no-cache avahi augeas tini && rm /etc/avahi/services/*
COPY docker-entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
