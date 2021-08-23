#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/* /val_keys/
  chown lsvalidator:lsvalidator /val_keys/*
  exec su-exec lsvalidator "$BASH_SOURCE" "$@"
fi

exec "$@"
