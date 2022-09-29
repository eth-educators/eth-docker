#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R teku:teku /var/lib/teku
  exec gosu teku docker-entrypoint.sh "$@"
fi

if [[ -f /var/lib/teku/teku-keyapi.keystore && $(date +%s -r /var/lib/teku/teku-keyapi.keystore) -gt $(date +%s --date="300 days ago") ]]; then
  rm /var/lib/teku/teku-keyapi.keystore
fi

if [ ! -f /var/lib/teku/teku-keyapi.keystore ]; then
    __password=$(echo $RANDOM | md5sum | head -c 32)
    echo $__password > /var/lib/teku/teku-keyapi.password
    openssl req -new --newkey rsa:2048 -nodes -keyout /var/lib/teku/teku-keyapi.key -out /var/lib/teku/teku-keyapi.csr -subj "/CN=127.0.0.1"
    openssl x509 -req -days 365 -in  /var/lib/teku/teku-keyapi.csr -signkey  /var/lib/teku/teku-keyapi.key -out  /var/lib/teku/teku-keyapi.crt
    openssl pkcs12 -export -in /var/lib/teku/teku-keyapi.crt -inkey /var/lib/teku/teku-keyapi.key -out /var/lib/teku/teku-keyapi.keystore -name teku-keyapi -passout pass:$__password
fi

# Check whether we should use MEV Boost
if [ "${MEV_BOOST}" = "true" ]; then
  __mev_boost="--validators-builder-registration-default-enabled"
  echo "MEV Boost enabled"
else
  __mev_boost=""
fi

exec "$@" ${__mev_boost}
