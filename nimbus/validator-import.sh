#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/* /val_keys/
  chown user:user /val_keys/*
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

if [ ${__non_interactive} = 1 ]; then
  echo "${KEYSTORE_PASSWORD}" > /tmp/keystorepassword.txt
  chmod 600 /tmp/keystorepassword.txt
  echo "Nimbus automated import is not yet functional"
  exec "$@"
fi

# Only reached in interactive mode
exec "$@"
