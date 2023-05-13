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

# Web3signer URL
if [ "${WEB3SIGNER}" = "true" ]; then
  __w3s_url="--validators-external-signer-url http://web3signer:9000"
else
  __w3s_url=""
fi

if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__w3s_url} ${__mev_boost} ${__doppel} ${VC_EXTRAS}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" "--graffiti" "${GRAFFITI}" ${__w3s_url} ${__mev_boost} ${__doppel} ${VC_EXTRAS}
fi
