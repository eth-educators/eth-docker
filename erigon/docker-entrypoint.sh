#!/bin/bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R erigon:erigon /var/lib/erigon
  exec su-exec erigon "${BASH_SOURCE}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/erigon/secrets/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/erigon/secrets/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/erigon/secrets/jwtsecret
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--override.terminaltotaldifficulty=${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

# Check for mainnet or goerli, and set prune accordingly

if [[ "$@" =~ "--chain mainnet" ]]; then
  echo "mainnet: Running with prune.r.before=11184524 for eth deposit contract"
  exec $@ --prune.r.before=11184524 ${__override_ttd}
elif [[ "$@" =~ "--chain goerli" ]]; then
  echo "goerli: Running with prune.r.before=4367322 for eth deposit contract"
  exec $@ --prune.r.before=4367322 ${__override_ttd}
elif [[ "$@" =~ "--chain ropsten" ]]; then
  echo "ropsten: Running with prune.r.before=12269949 for eth deposit contract"
  exec $@ --prune.r.before=12269949 ${__override_ttd}
else
  echo "Unable to determine eth deposit contract, running without prune.r.before"
  exec $@ ${__override_ttd}
fi
