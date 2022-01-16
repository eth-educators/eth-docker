#!/bin/bash
set -Eeuo pipefail

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
