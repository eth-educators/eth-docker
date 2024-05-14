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
  # In case someone specifies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/lighthouse/beacon/ee-secret
fi
if [[ -O "/var/lib/lighthouse/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/lighthouse/beacon/ee-secret/jwtsecret
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  # For want of something more amazing, let's just fail if git fails to pull this
  set -e
  if [ ! -d "/var/lib/lighthouse/beacon/testnet/${config_dir}" ]; then
    mkdir -p /var/lib/lighthouse/beacon/testnet
    cd /var/lib/lighthouse/beacon/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
  fi
  bootnodes="$(paste -s -d, "/var/lib/lighthouse/beacon/testnet/${config_dir}/bootstrap_nodes.txt")"
  set +e
  __network="--testnet-dir=/var/lib/lighthouse/beacon/testnet/${config_dir} --boot-nodes=${bootnodes}"
else
  __network="--network=${NETWORK}"
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL}" ]; then
  __rapid_sync="--checkpoint-sync-url=${RAPID_SYNC_URL}"
  echo "Checkpoint sync enabled"
  if [ "${ARCHIVE_NODE}" = "true" ]; then
    echo "Lighthouse archive node without pruning"
    __prune="--reconstruct-historic-states --genesis-backfill"
  else
    __prune=""
  fi
else
  __rapid_sync="--allow-insecure-genesis-sync"
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

if [ "${IPV6}" = "true" ]; then
  echo "Configuring Lighthouse to listen on IPv6 ports"
  __ipv6="--listen-address :: --port6 ${CL_P2P_PORT:-9000} --quic-port6 ${CL_QUIC_PORT:-9001}"
else
  __ipv6=""
fi

if [ -f /var/lib/lighthouse/beacon/prune-marker ]; then
  rm -f /var/lib/lighthouse/beacon/prune-marker
  if [ "${ARCHIVE_NODE}" = "true" ]; then
    echo "Lighthouse is an archive node. Not attempting to prune state: Aborting."
    exit 1
  fi
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec lighthouse db prune-states ${__network} --datadir /var/lib/lighthouse --confirm
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__network} ${__mev_boost} ${__rapid_sync} ${__prune} ${__beacon_stats} ${__ipv6} ${CL_EXTRAS}
fi
