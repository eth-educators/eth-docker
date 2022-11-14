#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R lsconsensus:lsconsensus /var/lib/lodestar
  exec su-exec lsconsensus docker-entrypoint.sh "$@"
fi

if [ ! -f /var/lib/lodestar/consensus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo "$__token" > /var/lib/lodestar/consensus/api-token.txt
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/lodestar/consensus/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ -O "/var/lib/lodestar/consensus/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/lodestar/consensus/ee-secret
fi
if [[ -O "/var/lib/lodestar/consensus/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/lodestar/consensus/ee-secret/jwtsecret
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--builder --builder.urls=${MEV_NODE:-http://mev-boost:18550}"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL}" ]; then
  __rapid_sync="--checkpointSyncUrl=${RAPID_SYNC_URL}"
  echo "Checkpoint sync enabled"
else
  __rapid_sync=""
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__mev_boost} ${__rapid_sync} ${CL_EXTRAS}
