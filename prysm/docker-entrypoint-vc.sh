#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R prysmvalidator:prysmvalidator /var/lib/prysm
  exec gosu prysmvalidator docker-entrypoint.sh "$@"
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--enable-builder"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel="--enable-doppelganger"
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel=""
fi

# Check whether we should use default graffiti
if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
  __graffiti_cmd=""
  __graffiti=""
else
  __graffiti_cmd="--graffiti"
  __graffiti="${GRAFFITI}"
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__graffiti_cmd} "${__graffiti}" ${__mev_boost} ${__doppel} ${VC_EXTRAS}
