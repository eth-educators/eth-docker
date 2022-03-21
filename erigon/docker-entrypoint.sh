#!/bin/bash
set -Eeuo pipefail

if [[ ! -f /var/lib/erigon/setupdone ]]; then
  erigon init --datadir=/var/lib/erigon /configs/genesis.json
  touch /var/lib/erigon/setupdone
fi

# Check for mainnet or goerli, and set prune accordingly

if [[ "$@" =~ "--chain mainnet" ]]; then
  echo "mainnet: Running with prune.r.before=11184524 for eth deposit contract"
  exec "$@" --prune.r.before=11184524
elif [[ "$@" =~ "--chain goerli" ]]; then
  echo "goerli: Running with prune.r.before=4367322 for eth deposit contract"
  exec "$@" --prune.r.before=4367322
else
  echo "Unable to determine eth deposit contract, running without prune.r.before"
  exec "$@"
fi
