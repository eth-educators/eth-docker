#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R prysmconsensus:prysmconsensus /var/lib/prysm
  exec gosu prysmconsensus docker-entrypoint.sh "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/prysm/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ -O "/var/lib/prysm/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/prysm/ee-secret
fi
if [[ -O "/var/lib/prysm/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/prysm/ee-secret/jwtsecret
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL:+x}" ]; then
  __rapid_sync="--checkpoint-sync-url=${RAPID_SYNC_URL}"
  echo "Checkpoint sync enabled"
else
  __rapid_sync=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--http-mev-relay=${MEV_NODE:-http://mev-boost:18550}"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Prysm archive node without pruning"
  __prune="--slots-per-archive-point=32"
else
  __prune=""
fi

# Fetch genesis file as needed if beacon
if [[ "$1" =~ ^(beacon-chain)$ ]]; then
  if [[ "$*" =~ --prater || "$*" =~ --goerli ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Goerli testnet"
      curl -fsSL -o "$GENESIS" https://github.com/eth-clients/eth2-networks/raw/master/shared/prater/genesis.ssz
    fi
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
    exec "$@" "--genesis-state=$GENESIS" ${__rapid_sync} ${__prune} ${__mev_boost} ${CL_EXTRAS}
  elif [[ "$*" =~ --sepolia ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Sepolia testnet"
      curl -fsSL -o "$GENESIS" https://github.com/eth-clients/merge-testnets/raw/main/sepolia/genesis.ssz
    fi
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
    exec "$@" "--genesis-state=$GENESIS" ${__rapid_sync} ${__prune} ${__mev_boost} ${CL_EXTRAS}
  else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
    exec "$@" ${__rapid_sync} ${__prune} ${__mev_boost} ${CL_EXTRAS}
  fi
else # Not the CL / beacon
  exec "$@"
fi
