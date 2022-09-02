#!/bin/bash

if [ ! -f /var/lib/lodestar/consensus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo $__token > /var/lib/lodestar/consensus/api-token.txt
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/lodestar/consensus/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ -O "/var/lib/lodestar/consensus/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/lodestar/consensus/ee-secret
fi
if [[ -O "/var/lib/lodestar/consensus/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/lodestar/consensus/ee-secret/jwtsecret
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--terminal-total-difficulty-override ${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--builder --builder.urls http://mev-boost:18550"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

if [ -n "${RAPID_SYNC_URL:+x}" -a ! -f "/var/lib/lodestar/consensus/setupdone" ]; then
    touch /var/lib/lodestar/consensus/setupdone
    echo "Checkpoint sync enabled"
    exec "$@" --checkpointSyncUrl=${RAPID_SYNC_URL} ${__mev_boost} ${__override_ttd}
fi

exec "$@" ${__mev_boost} ${__override_ttd}
