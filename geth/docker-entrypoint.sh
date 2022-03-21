#!/bin/bash
set -Eeuo pipefail

# Init from genesis file if needed
if [[ ! -f /var/lib/goethereum/setupdone ]]; then
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /secrets/jwtsecret
  cp /secrets/jwtsecret /var/lib/goethereum/
  chown 10001:10001 /var/lib/goethereum/jwtsecret
  chown 10002:10002 /secrets/jwtsecret
  touch /var/lib/goethereum/setupdone
  su-exec geth geth --datadir /var/lib/goethereum init /configs/genesis.json
fi

exec su-exec geth $@
