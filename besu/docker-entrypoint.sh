#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run besu as besu
if [ "$(id -u)" = '0' ]; then
   chown -R besu:besu /var/lib/besu

   exec gosu besu "$BASH_SOURCE" "$@"
fi

exec "$@"
