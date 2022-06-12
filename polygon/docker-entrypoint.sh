#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run bor as bor
if [ "$(id -u)" = '0' ]; then
   chown -R bor:bor /var/lib/bor
   exec su-exec bor "$BASH_SOURCE" "$@"
fi

if [ -f /var/lib/bor/prune-marker ]; then
  $@ snapshot prune-state
  rm -f /var/lib/bor/prune-marker
else
  set -x
  cd /var/lib/bor
  wget -O setup.sh ${BOR_SETUP}
  sed -i '/^cp .\/static-nodes.json/d' setup.sh
  sed -i '/^# set -x/c\set -x' setup.sh
  wget -O genesis.json ${BOR_GENESIS}
  chmod +x ./setup.sh
  ./setup.sh

  if [ ! -f /var/lib/bor/setupdone ]; then
    if [ ${BOR_MODE} == "archive" ]; then
      wget -q -O - "${BOR_ARCHIVE_NODE_SNAPSHOT_FILE}" | tar xzvf - -C /var/lib/bor/data/bor/chaindata
    else
      wget -q -O - "${BOR_FULL_NODE_SNAPSHOT_FILE}" | tar xzvf - -C /var/lib/bor/data/bor/chaindata
    fi
    touch /var/lib/bor/setupdone
  fi

  exec $@
fi
