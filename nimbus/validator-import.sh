#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/* /val_keys/
  chown user:user /val_keys/*
  exec gosu user "$BASH_SOURCE" "$@"
fi

exec "$@"
