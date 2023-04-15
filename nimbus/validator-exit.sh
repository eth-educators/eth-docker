#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /keys
  cp /validator_keys/* /keys/
  chown user:user /keys/*
  exec gosu user "${BASH_SOURCE[0]}" "$@"
fi

exec "$@"
