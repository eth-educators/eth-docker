#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R user:user /var/lib/nimbus
  exec gosu user docker-entrypoint.sh "$@"
fi

if [ ! -f /var/lib/nimbus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo "$__token" > /var/lib/nimbus/api-token.txt
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/nimbus/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ -O "/var/lib/nimbus/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/nimbus/ee-secret
fi
if [[ -O "/var/lib/nimbus/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/nimbus/ee-secret/jwtsecret
fi

if [ -n "${RAPID_SYNC_URL:+x}" ] && [ ! -f "/var/lib/nimbus/setupdone" ]; then
    if [ "${ARCHIVE_NODE}" = "true" ]; then
        echo "Starting checkpoint sync with backfill and archive reindex. Nimbus will restart when done."
        /usr/local/bin/nimbus_beacon_node trustedNodeSync --backfill=true --reindex --network="${NETWORK}" --data-dir=/var/lib/nimbus --trusted-node-url="${RAPID_SYNC_URL}"
        touch /var/lib/nimbus/setupdone
    else
        echo "Starting checkpoint sync. Nimbus will restart when done."
        /usr/local/bin/nimbus_beacon_node trustedNodeSync --backfill=false --network="${NETWORK}" --data-dir=/var/lib/nimbus --trusted-node-url="${RAPID_SYNC_URL}"
        touch /var/lib/nimbus/setupdone
    fi
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--payload-builder=true --payload-builder-url=${MEV_NODE:-http://mev-boost:18550}"
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

__log_level="--log-level=${LOG_LEVEL^^}"

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Nimbus archive node without pruning"
  __prune="--history=archive"
else
  __prune="--history=prune"
fi

if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__mev_boost} ${__log_level} ${__doppel} ${__prune} ${CL_EXTRAS} ${VC_EXTRAS}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" "--graffiti=${GRAFFITI}" ${__mev_boost} ${__log_level} ${__doppel} ${__prune} ${CL_EXTRAS} ${VC_EXTRAS}
fi
