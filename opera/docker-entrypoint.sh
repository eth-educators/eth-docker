#!/bin/bash
set -Eeuo pipefail

GENESIS=/var/lib/opera/mainnet.g
if [[ ! -f "$GENESIS" && -n "$GENESIS_FILE" ]]; then
  echo "Fetching genesis file for mainnet"
  wget -O "$GENESIS" "$GENESIS_FILE" 
else
  echo "Genesis file not found. Please specify GENESIS_FILE in .env"
  echo "and then ./ethd restart"
  exit 0
fi

exec "$@"
