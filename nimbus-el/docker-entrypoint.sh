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
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/nimbus/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/nimbus/ee-secret" ]]; then
  # In case someone specifies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/nimbus/ee-secret
fi
if [[ -O "/var/lib/nimbus/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/nimbus/ee-secret/jwtsecret
fi

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Nimbus EL does not support running an archive node"
  sleep 30
  exit 1
else
  if [ "${MINIMAL_NODE}" = "true" ]; then
    echo "Nimbus EL minimal node with pre-merge history expiry"
    __prune="--history-expiry=true"
  else
    __prune=""
  fi
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  # For want of something more amazing, let's just fail if git fails to pull this
  set -e
  if [ ! -d "/var/lib/nimbus/testnet/${config_dir}" ]; then
    mkdir -p /var/lib/nimbus/testnet
    cd /var/lib/nimbus/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
  fi
  bootnodes="$(awk -F'- ' '!/^#/ && NF>1 {print $2}' "/var/lib/nimbus/testnet/${config_dir}/enodes.yaml" | paste -sd ",")"
  networkid="$(jq -r '.config.chainId' "/var/lib/nimbus/testnet/${config_dir}/genesis.json")"
  set +e
  __network="--bootstrap-node=${bootnodes} --network=${networkid} --custom-network /var/lib/nimbus/testnet/${config_dir}/genesis.json"
else
  __network="--network=${NETWORK}"
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__prune} ${__network} ${EL_EXTRAS}
