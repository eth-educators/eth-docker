#!/bin/bash
set -Eeuo pipefail

if [[ ! -f /secrets/jwtsecret ]]; then
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/besu/secrets/jwtsecret
fi

exec $@
