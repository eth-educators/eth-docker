#!/bin/bash
set -Eeuo pipefail

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/lighthouse/beacon/secrets/jwtsecret
  echo "JWT secret was supplied in .env"
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL}" ]; then
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

exec $@ ${__rapid_sync} ${__override_ttd}
