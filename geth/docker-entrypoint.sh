#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run geth as geth
if [ "$(id -u)" = '0' ]; then
   chown -R geth:geth /var/lib/goethereum

   exec su-exec geth "$BASH_SOURCE" "$@"
fi

exec "$@"
