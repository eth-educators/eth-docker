#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R vero:vero /var/lib/vero
  exec gosu vero docker-entrypoint.sh "$@"
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  # For want of something more amazing, let's just fail if git fails to pull this
  set -e
  if [ ! -d "/var/lib/vero/testnet/${config_dir}" ]; then
    mkdir -p /var/lib/vero/testnet
    cd /var/lib/vero/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
  fi
  set +e
  __network="--network-custom-config-path=/var/lib/vero/testnet/${config_dir}/config.yaml"
else
  __network="--network ${NETWORK}"
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--use-external-builder"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should send stats to beaconcha.in
#if [ -n "${BEACON_STATS_API}" ]; then
#  __beacon_stats="--monitoring.endpoint https://beaconcha.in/api/v1/client/metrics?apikey=${BEACON_STATS_API}&machine=${BEACON_STATS_MACHINE}"
#  echo "Beacon stats API enabled"
#else
#  __beacon_stats=""
#fi

# Check whether we should enable doppelganger protection
#if [ "${DOPPELGANGER}" = "true" ]; then
#  __doppel="--doppelgangerProtection"
#  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
#else
#  __doppel=""
#fi

# Web3signer URL
if [ "${WEB3SIGNER}" = "true" ]; then
  __w3s_url="--remote-signer-url ${W3S_NODE}"
else
  echo "Vero requires the use of web3signer.yml and WEB3SIGNER=true. Please reconfigure to use Web3Signer and start again"
  sleep 60
  exit 1
fi

# Uppercase log level
__log_level="--log-level ${LOG_LEVEL^^}"

if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__network} ${__mev_boost} ${__w3s_url} ${__log_level} ${VC_EXTRAS}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__network} "--graffiti" "${GRAFFITI}" ${__mev_boost} ${__w3s_url} ${__log_level} ${VC_EXTRAS}
fi
