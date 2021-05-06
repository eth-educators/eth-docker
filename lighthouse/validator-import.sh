#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/* /val_keys/
  chown lhvalidator:lhvalidator /val_keys/*
  exec gosu lhvalidator "$BASH_SOURCE" "$@"
fi

# Ask whether all the validator passwords are the same, then call the parameters that had been passed in

while true; do
  read -rp "Do all validator keys have the same password? (y/n) " yn
  case $yn in
    [Yy]* ) justone=1; break;;
    [Nn]* ) justone=0; break;;
    * ) echo "Please answer yes or no.";;
  esac
done

if [ $justone -eq 1 ]; then
  exec "$@" --reuse-password
else
  exec "$@"
fi
