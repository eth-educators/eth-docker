#!/bin/bash
set -Eeuo pipefail

# Run prysm as prysmbeacon and fetch genesis file as needed
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
  echo "Could not determine that this is the consensus client."
  echo "This is a bug, please report it at https://github.com/eth2-educators/eth-docker/,"
  echo "and thank you."
  echo "Failed to match on" $1
  exit
fi
