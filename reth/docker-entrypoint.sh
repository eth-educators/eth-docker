#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R reth:reth /var/lib/reth
  exec gosu reth "${BASH_SOURCE[0]}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/reth/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/reth/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/reth/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/reth/ee-secret" ]]; then
  # In case someone specifies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/reth/ee-secret
fi
if [[ -O "/var/lib/reth/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/reth/ee-secret/jwtsecret
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  # For want of something more amazing, let's just fail if git fails to pull this
  set -e
  if [ ! -d "/var/lib/reth/testnet/${config_dir}" ]; then
    mkdir -p /var/lib/reth/testnet
    cd /var/lib/reth/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
  fi
  bootnodes="$(paste -s -d, "/var/lib/reth/testnet/${config_dir}/bootnode.txt")"
  set +e
  __network="--chain=/var/lib/reth/testnet/${config_dir}/genesis.json --bootnodes=${bootnodes}"
else
  __network="--chain ${NETWORK}"
fi

# Set verbosity
shopt -s nocasematch
case ${LOG_LEVEL} in
  error)
    __verbosity="-v"
    ;;
  warn)
    __verbosity="-vv"
    ;;
  info)
    __verbosity="-vvv"
    ;;
  debug)
    __verbosity="-vvvv"
    ;;
  trace)
    __verbosity="-vvvvv"
    ;;
  *)
    echo "LOG_LEVEL ${LOG_LEVEL} not recognized"
    __verbosity=""
    ;;
esac

__static=""
if [ -n "${STATIC_DIR}" ] && [ ! "${STATIC_DIR}" = ".nada" ]; then
  echo "Using separate static files directory at ${STATIC_DIR}."
  __static="--datadir.static-files /var/lib/static"
fi

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Reth archive node without pruning"
  __prune=""
else
  __prune="--full"
  if [ ! -f "/var/lib/reth/reth.toml" ]; then  # Configure ssv, rocketpool, stakewise contracts
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
    reth init ${__network} --datadir /var/lib/reth ${__static}
    cat <<EOF >> /var/lib/reth/reth.toml

[prune]
block_interval = 5

[prune.segments]
sender_recovery = "full"

[prune.segments.receipts]
before = 0

[prune.segments.account_history]
distance = 10064

[prune.segments.storage_history]
distance = 10064
EOF
    case "${NETWORK}" in
      mainnet)
        echo "Configuring Reth pruning to include RocketPool, SSV and StakeWise contracts"
        cat <<EOF >> /var/lib/reth/reth.toml

[prune.segments.receipts_log_filter.0x00000000219ab540356cBB839Cbe05303d7705Fa]
before = 0

[prune.segments.receipts_log_filter.0xDD9BC35aE942eF0cFa76930954a156B3fF30a4E1]
before = 0

[prune.segments.receipts_log_filter.0xEE4d2A71cF479e0D3d0c3c2C923dbfEB57E73111]
before = 0

[prune.segments.receipts_log_filter.0x6B5815467da09DaA7DC83Db21c9239d98Bb487b5]
before = 0
EOF
        ;;
      holesky)
        echo "Configuring Reth pruning to include RocketPool, SSV and StakeWise contracts"
        cat <<EOF >> /var/lib/reth/reth.toml

[prune.segments.receipts_log_filter.0x4242424242424242424242424242424242424242]
before = 0

[prune.segments.receipts_log_filter.0x38A4794cCEd47d3baf7370CcC43B560D3a1beEFA]
before = 0

[prune.segments.receipts_log_filter.0x9D210F9169bc6Cf49152F21A57A446bCcaA87b33]
before = 0

[prune.segments.receipts_log_filter.0xB580799Bf7d62721D1a523f0FDF2f5Ed7BA4e259]
before = 0
EOF
        ;;
    esac
  fi
fi

if [ -f /var/lib/reth/prune-marker ]; then
  rm -f /var/lib/reth/prune-marker
  if [ "${ARCHIVE_NODE}" = "true" ]; then
    echo "Reth is an archive node. Not attempting to prune database: Aborting."
    exit 1
  fi
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec reth prune ${__network} --datadir /var/lib/reth ${__static}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__network} ${__verbosity} ${__prune} ${__static} ${EL_EXTRAS}
fi
