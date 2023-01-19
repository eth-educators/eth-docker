#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R lhconsensus:lhconsensus /var/lib/lighthouse
  exec gosu lhconsensus docker-entrypoint.sh "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/lighthouse/beacon/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ -O "/var/lib/lighthouse/beacon/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/lighthouse/beacon/ee-secret
fi
if [[ -O "/var/lib/lighthouse/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/lighthouse/beacon/ee-secret/jwtsecret
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL}" ]; then
  __rapid_sync="--checkpoint-sync-url=${RAPID_SYNC_URL}"
  echo "Checkpoint sync enabled"
  if [ "${ARCHIVE_MODE}" = "true" ]; then
    echo "Lighthouse archive mode without pruning"
    __prune="--reconstruct-historic-states"
  else
    __prune=""
  fi
else
  __rapid_sync=""
  __prune=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--builder ${MEV_NODE:-http://mev-boost:18550}"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should send stats to beaconcha.in
if [ -n "${BEACON_STATS_API}" ]; then
  __beacon_stats="--monitoring-endpoint https://beaconcha.in/api/v1/client/metrics?apikey=${BEACON_STATS_API}&machine=${BEACON_STATS_MACHINE}"
  echo "Beacon stats API enabled"
else
  __beacon_stats=""
fi


# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__mev_boost} ${__rapid_sync} ${__prune} ${__beacon_stats} ${CL_EXTRAS}
