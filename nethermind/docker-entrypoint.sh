#!/bin/bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R nethermind:nethermind /var/lib/nethermind
  exec gosu nethermind "$BASH_SOURCE" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/nethermind/secrets/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/nethermind/secrets/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/nethermind/secrets/jwtsecret
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--Merge.TerminalTotalDifficulty ${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

exec $@ ${__override_ttd}
