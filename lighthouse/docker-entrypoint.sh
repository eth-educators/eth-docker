#!/bin/bash
set -Eeuo pipefail

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL}" ]; then
  __rapid_sync="--checkpoint-sync-url=${RAPID_SYNC_URL}"
else
  __rapid_sync=""
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/lighthouse/beacon/secrets/jwtsecret
  echo "JWT secret was supplied in .env"
fi

exec $@ ${__rapid_sync}
