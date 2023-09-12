#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R geth:geth /var/lib/goethereum
  exec su-exec geth docker-entrypoint.sh "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/goethereum/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/goethereum/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/goethereum/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/goethereum/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/goethereum/ee-secret
fi
if [[ -O "/var/lib/goethereum/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/goethereum/ee-secret/jwtsecret
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  # For want of something more amazing, let's just fail if git fails to pull this
  set -e
  if [ ! -d "/var/lib/goethereum/testnet/${config_dir}" ]; then
    mkdir -p /var/lib/goethereum/testnet
    cd /var/lib/goethereum/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
  fi
  bootnodes="$(paste -s -d, "/var/lib/goethereum/testnet/${config_dir}/bootnode.txt")"
  networkid="$(jq -r '.config.chainId' "/var/lib/goethereum/testnet/${config_dir}/genesis.json")"
  set +e
  __network="--bootnodes=${bootnodes} --networkid=${networkid} --http.api=eth,net,web3,debug,admin,txpool"
  if [ ! -d "/var/lib/goethereum/geth/chaindata/" ]; then
    geth init --state.scheme path --datadir /var/lib/goethereum "/var/lib/goethereum/testnet/${config_dir}/genesis.json"
  fi
else
  __network="--${NETWORK}"
fi

# Set verbosity
shopt -s nocasematch
case ${LOG_LEVEL} in
  error)
    __verbosity="--verbosity 1"
    ;;
  warn)
    __verbosity="--verbosity 2"
    ;;
  info)
    __verbosity="--verbosity 3"
    ;;
  debug)
    __verbosity="--verbosity 4"
    ;;
  trace)
    __verbosity="--verbosity 5"
    ;;
  *)
    echo "LOG_LEVEL ${LOG_LEVEL} not recognized"
    __verbosity=""
    ;;
esac

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Geth archive node without pruning"
  __prune="--syncmode=full --gcmode=archive"
else
  __prune=""
fi

# Detect existing DB; use PBSS if fresh
if [ -d "/var/lib/goethereum/geth/chaindata/" ]; then
  __pbss=""
else
  if [ "${ARCHIVE_NODE}" = "true" ]; then
    echo "Geth is an archive node. Syncing without PBSS."
    _pbss=""
  else
    echo "Choosing PBSS for fresh sync"
    __pbss="--state.scheme path"
  fi
fi

if [ -f /var/lib/goethereum/prune-marker ]; then
  rm -f /var/lib/goethereum/prune-marker
  if [ "${ARCHIVE_NODE}" = "true" ]; then
    echo "Geth is an archive node. Not attempting to prune: Aborting."
    exit 1
  fi
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__network} ${EL_EXTRAS} snapshot prune-state
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__pbss} ${__network} ${__prune} ${__verbosity} ${EL_EXTRAS}
fi
