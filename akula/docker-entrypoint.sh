#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R akula:akula /var/lib/akula
  exec gosu akula "${BASH_SOURCE[0]}" "$@"
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/akula/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/akula/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/akula/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/akula/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/akula/ee-secret
fi
if [[ -O "/var/lib/akula/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/akula/ee-secret/jwtsecret
fi

# Check for network, and set prune accordingly
# This is not possible in Akula presently!
if false; then
if [[ "$*" =~ "--chain mainnet" ]]; then
#  echo "mainnet: Running with prune.r.before=11184524 for eth deposit contract"
#  __prune="--prune.r.before=11184524"
  echo "mainnet: Running with prune.r.before=11052984 for eth deposit contract"
  __prune="--prune.r.before=11052984"
elif [[ "$*" =~ "--chain goerli" ]]; then
  echo "goerli: Running with prune.r.before=4367322 for eth deposit contract"
  __prune="--prune.r.before=4367322"
elif [[ "$*" =~ "--chain ropsten" ]]; then
  echo "ropsten: Running with prune.r.before=12269949 for eth deposit contract"
  __prune="--prune.r.before=12269949"
elif [[ "$*" =~ "--chain sepolia" ]]; then
  echo "sepolia: Running with prune.r.before=1273020 for eth deposit contract"
  __prune="--prune.r.before=1273020"
else
  echo "Unable to determine eth deposit contract, running without prune.r.before"
  __prune=""
fi
fi

# No log levels yet in Akula
if false; then
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
fi

#exec "$@" ${__prune} ${__verbosity} ${EL_EXTRAS}
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${EL_EXTRAS}
