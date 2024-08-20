#!/bin/sh

# shellcheck disable=SC3040
set -euo pipefail

# update the configuration from the environment variables
env | awk '
BEGIN {
    FS = "=|__"
}
function transform(name) {
    gsub(/_/, "-", name)
    return tolower(name)
}
NF==3 {
    print "set /files/etc/avahi/avahi-daemon.conf/" transform($1) "/" transform($2) " " $3
}
' | augtool -s >/dev/null

# run the avahi daemon
exec avahi-daemon "$@"
