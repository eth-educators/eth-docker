#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run teku as teku
if [ "$(id -u)" = '0' ]; then
   chown -R teku:teku /var/lib/teku

   exec gosu teku "$BASH_SOURCE" "$@"
fi

exec "$@"
