#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run prysm as prysmbeacon or prysmvalidator, depending
if [ "$(id -u)" = '0' ]; then
  if [[ "$1" =~ ^(beacon-chain|slasher)$ ]]; then
    chown -R prysmconsensus:prysmconsensus /var/lib/prysm
    if [[ "$@" =~ --prater ]]; then
      GENESIS=/var/lib/prysm/genesis.ssz
      if [ ! -f "$GENESIS" ]; then
        echo "Fetching genesis file for Prater testnet"
        gosu prysmconsensus curl -o "$GENESIS" https://prysmaticlabs.com/uploads/prater-genesis.ssz
      fi
      exec gosu prysmconsensus "$BASH_SOURCE" "$@" "--genesis-state=$GENESIS"
    else
      exec gosu prysmconsensus "$BASH_SOURCE" "$@"
    fi
  elif [ "$1" = 'validator' ]; then
    chown -R prysmvalidator:prysmvalidator /var/lib/prysm
    exec gosu prysmvalidator "$BASH_SOURCE" "$@"
  else
    echo "Could not determine whether beacon or validator client."
    echo "This is a bug, please report it at https://github.com/eth2-educators/eth2-docker/,"
    echo "and thank you."
    echo "Failed to match on" $1
    exit
  fi
fi

exec "$@"
