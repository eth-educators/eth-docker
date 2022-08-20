#!/bin/bash
set -Eeuo pipefail

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/prysm/ee-secret/jwtsecret
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
else
  __rapid_sync=""
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--terminal-total-difficulty-override=${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--http-mev-relay=http://mev-boost:18550"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Fetch genesis file as needed if beacon
if [[ "$1" =~ ^(beacon-chain)$ ]]; then
  if [[ "$@" =~ --prater || "$@" =~ --goerli ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Goerli testnet"
      curl -fsSL -o "$GENESIS" https://github.com/eth-clients/eth2-networks/raw/master/shared/prater/genesis.ssz
    fi
    exec "$@" "--genesis-state=$GENESIS" ${__rapid_sync} ${__override_ttd} ${__mev_boost}
  elif [[ "$@" =~ --ropsten ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Ropsten testnet"
      curl -fsSL -o "$GENESIS" https://github.com/eth-clients/merge-testnets/raw/main/ropsten-beacon-chain/genesis.ssz
    fi
    exec "$@" "--genesis-state=$GENESIS" ${__rapid_sync} ${__override_ttd} ${__mev_boost}
  elif [[ "$@" =~ --sepolia ]]; then
    GENESIS=/var/lib/prysm/genesis.ssz
    if [ ! -f "$GENESIS" ]; then
      echo "Fetching genesis file for Sepolia testnet"
      curl -fsSL -o "$GENESIS" https://github.com/eth-clients/merge-testnets/raw/main/sepolia/genesis.ssz
    fi
    exec "$@" "--genesis-state=$GENESIS" ${__rapid_sync} ${__override_ttd} ${__mev_boost}
  else
    exec "$@" ${__rapid_sync} ${__override_ttd} ${__mev_boost}
  fi
else # Not the CL / beacon
  exec "$@"
fi
