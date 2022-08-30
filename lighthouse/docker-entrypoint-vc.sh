#!/bin/bash
set -Eeuo pipefail

# Check whether we should flag override TTD in VC logs
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--terminal-total-difficulty-override=${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--builder-proposals"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should send stats to beaconcha.in
if [ -n "${BEACON_STATS_API}" ]; then
  __beacon_stats="--monitoring-endpoint https://beaconcha.in/api/v1/client/metrics?apikey=${BEACON_STATS_API}&machine=${BEACON_STATS_MACHINE}"
else
  __beacon_stats=""
fi

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel="--enable-doppelganger-protection"
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel=""
fi

exec "$@" ${__mev_boost} ${__beacon_stats} ${__override_ttd} ${__doppel}
