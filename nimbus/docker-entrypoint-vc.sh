#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R vc-user:vc-user /var/lib/nimbus-vc
  exec gosu vc-user docker-entrypoint-vc.sh "$@"
fi

if [ ! -f /var/lib/nimbus-vc/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo "$__token" > /var/lib/nimbus-vc/api-token.txt
fi

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel=""
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel="--doppelganger-detection=false"
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__doppel} ${VC_EXTRAS}
