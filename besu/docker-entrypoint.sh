#!/bin/bash
set -Eeuo pipefail

if [[ ! -f /secrets/jwtsecret ]]; then
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /secrets/jwtsecret
fi

cp /secrets/jwtsecret /var/lib/besu/
chown 10001:10001 /var/lib/besu/jwtsecret
chown 10002:10002 /secrets/jwtsecret

exec gosu besu $@
