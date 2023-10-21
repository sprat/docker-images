#!/usr/bin/env bash
exec dehydrated --cron --accept-terms --domain "$DOMAIN" --domain "*.$DOMAIN"
# https://github.com/dehydrated-io/dehydrated/archive/master.tar.gz
# ENTRYPOINT ["dehydrated"]
