#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R user:user /var/lib/nimbus
  exec gosu user docker-entrypoint.sh "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/nimbus/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/nimbus/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 4 /dev/urandom | od -A n -t u4 | tr -d '[:space:]' | md5sum | head -c 32)
  __secret2=$(head -c 4 /dev/urandom | od -A n -t u4 | tr -d '[:space:]' | md5sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/nimbus/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/nimbus/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/nimbus/ee-secret
fi
if [[ -O "/var/lib/nimbus/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/nimbus/ee-secret/jwtsecret
fi

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Nimbus EL archive node without pruning"
  __prune="--prune-mode=Archive --sync-mode=Full"
else
  __prune=""
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__prune} ${EL_EXTRAS}
