#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
  chown -R geth:geth /var/lib/goethereum
  exec su-exec geth docker-entrypoint.sh "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/goethereum/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/goethereum/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/goethereum/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/goethereum/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/goethereum/ee-secret
fi
if [[ -O "/var/lib/goethereum/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/goethereum/ee-secret/jwtsecret
fi

# Set verbosity
shopt -s nocasematch
case ${LOG_LEVEL} in
  error)
    __verbosity="--verbosity 1"
    ;;
  warn)
    __verbosity="--verbosity 2"
    ;;
  info)
    __verbosity="--verbosity 3"
    ;;
  debug)
    __verbosity="--verbosity 4"
    ;;
  trace)
    __verbosity="--verbosity 5"
    ;;
  *)
    echo "LOG_LEVEL ${LOG_LEVEL} not recognized"
    __verbosity=""
    ;;
esac

if [ -f /var/lib/goethereum/prune-marker ]; then
  "$@" ${EL_EXTRAS} snapshot prune-state
  rm -f /var/lib/goethereum/prune-marker
else
  exec "$@" ${__verbosity} ${EL_EXTRAS}
fi
