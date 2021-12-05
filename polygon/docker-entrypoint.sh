#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run bor as bor
if [ "$(id -u)" = '0' ]; then
   chown -R bor:bor /var/lib/bor
   exec su-exec bor "$BASH_SOURCE" "$@"
fi

set -x
cd /var/lib/bor
wget -O setup.sh ${BOR_SETUP}
sed -i '/^cp .\/static-nodes.json/d' setup.sh
sed -i '/^# set -x/c\set -x' setup.sh
wget -O genesis.json ${BOR_GENESIS}
chmod +x ./setup.sh
./setup.sh
if [ ! -f /var/lib/bor/setupdone ]; then
  mkdir -p /var/lib/bor/snapshot
  if [ ${BOR_MODE} == "archive" ]; then
    wget -O /var/lib/bor/snapshot/borsnap.tgz ${BOR_ARCHIVE_NODE_SNAPSHOT_FILE}
  else
    wget -O /var/lib/bor/snapshot/borsnap.tgz ${BOR_FULL_NODE_SNAPSHOT_FILE}
  fi
  tar -xzvf /var/lib/bor/snapshot/borsnap.tgz -C /var/lib/bor/data/bor/chaindata
  rm /var/lib/bor/snapshot/borsnap.tgz
  touch /var/lib/bor/setupdone
fi

exec "$@"
