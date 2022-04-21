#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/* /val_keys/
  chown lhvalidator:lhvalidator /val_keys/*
  exec gosu lhvalidator "$BASH_SOURCE" "$@"
fi

__non_interactive=0
if echo "$@" | grep -q '.*--non-interactive.*' 2>/dev/null ; then
  __non_interactive=1
fi

if [ -f /val_keys/slashing_protection.json ]; then
  echo "Found slashing protection file, it will be imported."
  lighthouse account_manager validator slashing-protection import --datadir /var/lib/lighthouse --network ${NETWORK} /val_keys/slashing_protection.json
fi

for arg do
  shift
  [ "$arg" = "--non-interactive" ] && continue
  set -- "$@" "$arg"
done

if [ ${__non_interactive} = 1 ]; then
  echo "${KEYSTORE_PASSWORD}" > /tmp/keystorepassword.txt
  chmod 600 /tmp/keystorepassword.txt
  exec "$@" --reuse-password --password-file /tmp/keystorepassword.txt
fi

# Only reached in interactive mode
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
