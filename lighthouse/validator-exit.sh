#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /keys
  cp /validator_keys/* /keys/
  chown lhvalidator:lhvalidator /keys/*
  exec gosu lhvalidator "$BASH_SOURCE" "$@"
fi

exec "$@"
