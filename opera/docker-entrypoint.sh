#!/bin/bash
set -Eeuo pipefail

GENESIS=/var/lib/opera/mainnet.g
if [ ! -f "$GENESIS" ]; then
  echo "Fetching genesis file for mainnet"
  wget -O "$GENESIS" https://opera.fantom.network/mainnet.g
fi

exec "$@"
