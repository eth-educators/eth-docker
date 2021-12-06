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

# Fetch genesis file as needed if beacon
if [[ "$1" =~ ^(beacon-chain)$ ]]; then
  if [[ "$@" =~ --prater ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Prater testnet"
      curl -o "$GENESIS" https://prysmaticlabs.com/uploads/prater-genesis.ssz
    fi
    exec "$@" "--genesis-state=$GENESIS"
  else
    exec "$@"
  fi
else
  exec "$@"
fi
