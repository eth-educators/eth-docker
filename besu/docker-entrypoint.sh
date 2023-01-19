#!/bin/bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R besu:besu /var/lib/besu
  exec gosu besu "${BASH_SOURCE[0]}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/besu/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/besu/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/besu/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/besu/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/besu/ee-secret
fi
if [[ -O "/var/lib/besu/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/besu/ee-secret/jwtsecret
fi

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Besu archive node without pruning"
  __prune="--data-storage-format=FOREST --sync-mode=FULL"
else
  __prune="--data-storage-format=BONSAI --sync-mode=X_SNAP"
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__prune} ${EL_EXTRAS}
