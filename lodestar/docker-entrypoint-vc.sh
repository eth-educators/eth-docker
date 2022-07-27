#!/bin/bash
set -Eeuo pipefail

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--builder.enabled"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

exec "$@" ${__mev_boost}
