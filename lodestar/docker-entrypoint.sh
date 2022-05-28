#!/bin/bash

if [ ! -f /var/lib/lodestar/consensus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo $__token > /var/lib/lodestar/consensus/api-token.txt
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/lodestar/consensus/secrets/jwtsecret
  echo "JWT secret was supplied in .env"
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--terminal-total-difficulty-override ${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

if [ -n "${RAPID_SYNC_URL:+x}" -a ! -f "/var/lib/lodestar/consensus/setupdone" ]; then
    touch /var/lib/lodestar/consensus/setupdone
    exec $@ --weakSubjectivitySyncLatest=true --weakSubjectivityServerUrl=${RAPID_SYNC_URL} ${__override_ttd}
fi

exec $@ ${__override_ttd}
