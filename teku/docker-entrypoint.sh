#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R teku:teku /var/lib/teku
  exec gosu teku docker-entrypoint.sh "$@"
fi

if [ -f /var/lib/teku/teku-keyapi.keystore ]; then
    if [ "$(date +%s -r /var/lib/teku/teku-keyapi.keystore)" -lt "$(date +%s --date="300 days ago")" ]; then
       rm /var/lib/teku/teku-keyapi.keystore
    elif ! openssl x509 -noout -ext subjectAltName -in /var/lib/teku/teku-keyapi.crt | grep -q 'DNS:consensus'; then
       rm /var/lib/teku/teku-keyapi.keystore
    fi
fi

if [ ! -f /var/lib/teku/teku-keyapi.keystore ]; then
    __password=$(echo $RANDOM | md5sum | head -c 32)
    echo "$__password" > /var/lib/teku/teku-keyapi.password
    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -keyout /var/lib/teku/teku-keyapi.key -out /var/lib/teku/teku-keyapi.crt -subj '/CN=teku-keyapi-cert' -extensions san -config <( \
      echo '[req]'; \
      echo 'distinguished_name=req'; \
      echo '[san]'; \
      echo 'subjectAltName=DNS:localhost,DNS:consensus,DNS:validator,IP:127.0.0.1')
    openssl pkcs12 -export -in /var/lib/teku/teku-keyapi.crt -inkey /var/lib/teku/teku-keyapi.key -out /var/lib/teku/teku-keyapi.keystore -name teku-keyapi -passout pass:"$__password"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/teku/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ -O "/var/lib/teku/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/teku/ee-secret
fi
if [[ -O "/var/lib/teku/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/teku/ee-secret/jwtsecret
fi

# Check whether we should rapid sync
if [ -n "${RAPID_SYNC_URL:+x}" ]; then
    if [ "${ARCHIVE_NODE}" = "true" ]; then
        echo "Besu archive node cannot use checkpoint sync: Syncing from genesis."
        __rapid_sync=""
    else
        __rapid_sync="--initial-state=${RAPID_SYNC_URL}/eth/v2/debug/beacon/states/finalized"
        echo "Checkpoint sync enabled"
    fi
else
    __rapid_sync=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--validators-builder-registration-default-enabled --builder-endpoint=${MEV_NODE:-http://mev-boost:18550}"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

# Check whether we should send stats to beaconcha.in
if [ -n "${BEACON_STATS_API}" ]; then
  __beacon_stats="--metrics-publish-endpoint=https://beaconcha.in/api/v1/client/metrics?apikey=${BEACON_STATS_API}&machine=${BEACON_STATS_MACHINE}"
  echo "Beacon stats API enabled"
else
  __beacon_stats=""
fi

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel="--doppelganger-detection-enabled=true"
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel=""
fi

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Besu archive node without pruning"
  __prune="--data-storage-mode=ARCHIVE"
else
  __prune="--data-storage-mode=MINIMAL"
fi

if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__mev_boost} ${__rapid_sync} ${__prune} ${__beacon_stats} ${__doppel} ${CL_EXTRAS} ${VC_EXTRAS}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" "--validators-graffiti=${GRAFFITI}" ${__mev_boost} ${__rapid_sync} ${__prune} ${__beacon_stats} ${__doppel} ${CL_EXTRAS} ${VC_EXTRAS}
fi
