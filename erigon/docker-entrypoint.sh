#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R erigon:erigon /var/lib/erigon
  exec su-exec erigon "${BASH_SOURCE[0]}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/erigon/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/erigon/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/erigon/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/erigon/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/erigon/ee-secret
fi
if [[ -O "/var/lib/erigon/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/erigon/ee-secret/jwtsecret
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  # For want of something more amazing, let's just fail if git fails to pull this
  set -e
  if [ ! -d "/var/lib/erigon/testnet/${config_dir}" ]; then
    mkdir -p /var/lib/erigon/testnet
    cd /var/lib/erigon/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
  fi
  bootnodes="$(paste -s -d, "/var/lib/erigon/testnet/${config_dir}/bootnode.txt")"
  networkid="$(jq -r '.config.chainId' "/var/lib/erigon/testnet/${config_dir}/genesis.json")"
  set +e
  __network="--bootnodes=${bootnodes} --networkid=${networkid} --http.api=eth,erigon,engine,web3,net,debug,trace,txpool,admin"
  if [ ! -d /var/lib/erigon/chaindata ]; then
    erigon init --datadir /var/lib/erigon "/var/lib/erigon/testnet/${config_dir}/genesis.json"
  fi
else
  __network="--chain ${NETWORK} --http.api web3,eth,net,engine"
fi

# Check for network, and set prune accordingly

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Erigon archive node without pruning"
  __prune=""
else
  if [[ "${NETWORK}" = "mainnet" ]]; then
    echo "mainnet: Running with prune.r.before=11052984 for eth deposit contract"
    __prune="--prune=htc --prune.r.before=11052984"
  elif [[ "${NETWORK}" = "goerli" ]]; then
    echo "goerli: Running with prune.r.before=4367322 for eth deposit contract"
    __prune="--prune=htc --prune.r.before=4367322"
  elif [[ "${NETWORK}" = "sepolia" ]]; then
    echo "sepolia: Running with prune.r.before=1273020 for eth deposit contract"
    __prune="--prune=htc --prune.r.before=1273020"
  elif [[ "${NETWORK}" = "gnosis" ]]; then
    echo "gnosis: Running with prune.r.before=19469077 for gno deposit contract"
    __prune="--prune=htc --prune.r.before=19469077"
  elif [[ "${NETWORK}" = "holesky" ]]; then
    echo "holesky: Running without prune.r for eth deposit contract"
    __prune="--prune=htc"
  elif [[ "${NETWORK}" =~ ^https?:// ]]; then
    echo "Custom testnet: Running without prune.r for eth deposit contract"
    __prune="--prune=htc"
  else
    echo "Unable to determine eth deposit contract, running without prune.r"
    __prune="--prune=htc"
  fi
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__network} ${__prune} ${EL_EXTRAS}
