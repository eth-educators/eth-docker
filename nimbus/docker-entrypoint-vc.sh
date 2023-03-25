#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R user:user /var/lib/nimbus
  exec gosu user docker-entrypoint-vc.sh "$@"
fi

if [ ! -f /var/lib/nimbus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo "$__token" > /var/lib/nimbus/api-token.txt
fi

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel="--doppelganger-detection=true"
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel="--doppelganger-detection=false"
fi

__log_level="--log-level=${LOG_LEVEL^^}"

if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__log_level} ${__doppel} ${VC_EXTRAS}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" "--graffiti=${GRAFFITI}" ${__log_level} ${__doppel} ${VC_EXTRAS}
fi
