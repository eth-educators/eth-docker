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

# Check whether we should enable doppelganger protection
if [ "${DOPPELGANGER}" = "true" ]; then
  __doppel="--doppelganger-detection-enabled=true"
  echo "Doppelganger protection enabled, VC will pause for 2 epochs"
else
  __doppel=""
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--validators-builder-registration-default-enabled"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

if [ "${DEFAULT_GRAFFITI}" = "true" ]; then
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__mev_boost} ${__doppel} ${VC_EXTRAS}
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" "--validators-graffiti=${GRAFFITI}" ${__mev_boost} ${__doppel} ${VC_EXTRAS}
fi
