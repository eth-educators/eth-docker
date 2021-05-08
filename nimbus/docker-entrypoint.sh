#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run nimbus as user
if [ "$(id -u)" = '0' ]; then
   chown -R user:user /var/lib/nimbus

   exec gosu user "$BASH_SOURCE" "$@"
fi

exec "$@"
