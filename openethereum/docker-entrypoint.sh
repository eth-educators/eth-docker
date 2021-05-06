#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run openethereum as openethereum
if [ "$(id -u)" = '0' ]; then
   chown -R openethereum:openethereum /var/lib/openethereum

   exec su-exec openethereum "$BASH_SOURCE" "$@"
fi

exec "$@"
