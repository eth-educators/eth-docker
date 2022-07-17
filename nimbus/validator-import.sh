#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/*.json /val_keys/
  chown -R user:user /val_keys/
  exec gosu user "$BASH_SOURCE" "$@"
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

if [ -f /val_keys/slashing_protection.json ]; then
  echo "Found slashing protection file, it will be imported."
  /usr/local/bin/nimbus_beacon_node --data-dir=/var/lib/nimbus --network=${NETWORK} slashingdb import /val_keys/slashing_protection.json
  rm /val_keys/slashing_protection.json
fi

if [ ${__non_interactive} = 1 ]; then
  echo ${KEYSTORE_PASSWORD} | $@
  exit 0
fi

# Only reached in interactive mode
exec "$@"
