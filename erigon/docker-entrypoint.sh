#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R erigon:erigon /var/lib/erigon
  exec su-exec erigon "${BASH_SOURCE}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/erigon/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/erigon/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/erigon/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/erigon/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/erigon/ee-secret
fi
if [[ -O "/var/lib/erigon/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/erigon/ee-secret/jwtsecret
fi

# Check for network, and set prune accordingly

if [[ "$@" =~ "--chain mainnet" ]]; then
#  echo "mainnet: Running with prune.r.before=11184524 for eth deposit contract"
#  __prune="--prune.r.before=11184524"
  echo "mainnet: Running with prune.r.before=11052984 for eth deposit contract"
  __prune="--prune.r.before=11052984"
elif [[ "$@" =~ "--chain goerli" ]]; then
  echo "goerli: Running with prune.r.before=4367322 for eth deposit contract"
  __prune="--prune.r.before=4367322"
elif [[ "$@" =~ "--chain ropsten" ]]; then
  echo "ropsten: Running with prune.r.before=12269949 for eth deposit contract"
  __prune="--prune.r.before=12269949"
elif [[ "$@" =~ "--chain sepolia" ]]; then
  echo "sepolia: Running with prune.r.before=1273020 for eth deposit contract"
  __prune="--prune.r.before=1273020"
else
  echo "Unable to determine eth deposit contract, running without prune.r.before"
  __prune=""
fi

exec "$@" ${__prune} ${EL_EXTRAS}
