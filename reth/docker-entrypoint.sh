#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R reth:reth /var/lib/reth
  exec gosu reth "${BASH_SOURCE[0]}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/reth/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/reth/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/reth/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/reth/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/reth/ee-secret
fi
if [[ -O "/var/lib/reth/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/reth/ee-secret/jwtsecret
fi

# Set verbosity
shopt -s nocasematch
case ${LOG_LEVEL} in
  error)
    __verbosity="-v"
    ;;
  warn)
    __verbosity="-vv"
    ;;
  info)
    __verbosity="-vvv"
    ;;
  debug)
    __verbosity="-vvvv"
    ;;
  trace)
    __verbosity="-vvvvv"
    ;;
  *)
    echo "LOG_LEVEL ${LOG_LEVEL} not recognized"
    __verbosity=""
    ;;
esac

if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Reth archive node without pruning"
  __prune=""
else
  __prune="--full"
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__verbosity} ${__prune} ${EL_EXTRAS}
