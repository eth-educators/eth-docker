#!/bin/bash
set -Eeuo pipefail

# Create jwtsecret as root
if [ "$(id -u)" = '0' ]; then
    if [[ ! -f /secrets/jwtsecret ]]; then
      __secret1=$(echo $RANDOM | md5sum | head -c 32)
      __secret2=$(echo $RANDOM | md5sum | head -c 32)
      echo -n ${__secret1}${__secret2} > /secrets/jwtsecret
    fi
    cp /secrets/jwtsecret /var/lib/erigon/jwtsecret
    chown 10001:10001 /var/lib/erigon/jwtsecret
    chown 10002:10002 /secrets/jwtsecret
    exec su-exec erigon "$BASH_SOURCE" "$@"
fi

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
