#!/bin/bash

if [ ! -f /var/lib/nimbus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo $__token > /var/lib/nimbus/api-token.txt
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/nimbus/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--terminal-total-difficulty-override=${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

if [ -n "${RAPID_SYNC_URL:+x}" -a ! -f "/var/lib/nimbus/setupdone" ]; then
    touch /var/lib/nimbus/setupdone
    exec /usr/local/bin/nimbus_beacon_node trustedNodeSync --backfill=false --network=${NETWORK} --data-dir=/var/lib/nimbus --trusted-node-url=${RAPID_SYNC_URL} ${__override_ttd}
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--payload-builder-enable --payload-builder-url=http://mev-boost:18550"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel=""
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel="--doppelganger-detection=false"
fi

exec "$@" ${__mev_boost} ${__override_ttd} ${__doppel}
