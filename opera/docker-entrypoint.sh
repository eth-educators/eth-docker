#!/bin/bash
set -Eeuo pipefail

GENESIS=/var/lib/opera/mainnet.g
if [[ ! -f "/var/lib/opera/setupdone" ]]; then
  if [[ -n "$GENESIS_FILE" ]]; then
    echo "Fetching genesis file for mainnet"
    wget -O "$GENESIS" "$GENESIS_FILE"
    touch /var/lib/opera/setupdone
    exec "$@" --genesis "$GENESIS"
  else
    echo "Genesis file not found. Please specify GENESIS_FILE in .env"
    echo "and then ./ethd restart"
    exit 0
  fi
fi

if [[ -f "/var/lib/opera/setupdone" && -f "$GENESIS" ]]; then
  echo "Removing processed Genesis file"
  rm "$GENESIS"
fi

exec "$@"
