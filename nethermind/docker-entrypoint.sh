#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run nethermind as nethermind
if [ "$(id -u)" = '0' ]; then
   chown -R nethermind:nethermind /var/lib/nethermind /nethermind

   exec gosu nethermind "$BASH_SOURCE" "$@"
fi

exec "$@"
