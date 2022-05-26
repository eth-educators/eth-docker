#!/bin/bash
set -Eeuo pipefail

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/besu/secrets/jwtsecret
  echo "Secret was supplied"
fi

if [[ ! -f /var/lib/besu/secrets/jwtsecret ]]; then
  echo "Writing secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/besu/secrets/jwtsecret
fi

exec $@
