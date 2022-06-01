#!/bin/bash
set -Eeuo pipefail

# prysm-web never used the chown, fix this now. To be removed after merge.
if [ "$(id -u)" = '0' ]; then
  if [ "$1" = 'validator' ]; then
    chown -R prysmvalidator:prysmvalidator /var/lib/prysm
    exec gosu prysmvalidator "$BASH_SOURCE" "$@"
  else
    echo "Could not determine that this is the validator client."
    echo "This is a bug, please report it at https://github.com/eth2-educators/eth-docker/,"
    echo "and thank you."
    echo "Failed to match on" $1
    exit
  fi
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL:+x}" ]; then
  __rapid_sync="--checkpoint-sync-url=${RAPID_SYNC_URL}"
else
  __rapid_sync=""
fi

# Fetch genesis file as needed if beacon
if [[ "$1" =~ ^(beacon-chain)$ ]]; then
  if [[ "$@" =~ --prater ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Prater testnet"
      curl -o "$GENESIS" https://github.com/eth-clients/eth2-networks/raw/master/shared/prater/genesis.ssz
    fi
    exec $@ "--genesis-state=$GENESIS" ${__rapid_sync}
  else
    exec $@ ${__rapid_sync}
  fi
else
  exec $@
fi
