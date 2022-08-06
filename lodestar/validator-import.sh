#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/*.json /val_keys/
  chown -R lsvalidator:lsvalidator /val_keys
  exec su-exec lsvalidator "$BASH_SOURCE" "$@"
fi

__non_interactive=0
if echo "$@" | grep -q '.*--non-interactive.*' 2>/dev/null ; then
  __non_interactive=1
fi
for arg do
  shift
  [ "$arg" = "--non-interactive" ] && continue
  set -- "$@" "$arg"
done

shopt -s nullglob
for file in /val_keys/slashing_protection*.json; do
  echo "Found slashing protection file ${file}, it will be imported."
  echo "Pausing for 30s so consensus can start"
  sleep 30
  node --max-old-space-size=6144 /usr/app/node_modules/.bin/lodestar validator slashing-protection import --server ${CL_NODE} --rootDir /var/lib/lodestar/validators --network ${NETWORK} --file ${file}
done

if [ ${__non_interactive} = 1 ]; then
  echo "${KEYSTORE_PASSWORD}" > /tmp/keystorepassword.txt
  chmod 600 /tmp/keystorepassword.txt
  exec "$@" --passphraseFile /tmp/keystorepassword.txt
fi

# Only reached in interactive mode
exec "$@"
