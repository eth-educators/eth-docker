#!/bin/bash
set -Eeuo pipefail

# This will be started as root, so the generated files can be copied when done

# Find --uid if it exists, parse and discard. Used to chown after.
# Ditto --folder, since this now copies we need to parse it out
ARGS=()
foundu=0
foundf=0
uid=1000
folder="ethdo"
for var in "$@"; do
  if [ "$var" = '--uid' ]; then
    foundu=1
    continue
  fi
  if [ "$var" = '--folder' ]; then
    foundf=1
    continue
  fi
  if [ "$foundu" = '1' ]; then
    foundu=0
    if ! [[ $var =~ ^[0-9]+$ ]] ; then
      echo "error: Passed user ID is not a number, ignoring"
      continue
    fi
    uid="$var"
    continue
  fi
  if [ "$foundf" = '1' ]; then
    foundf=0
    folder="$var"
    continue
  fi
  ARGS+=("$var")
done

__sending=0
if [[ "$@" =~ "validator credentials set" ]] && [[ ! "$@" =~ "--prepare-offline" ]]; then
  if [ -f "/app/.eth/ethdo/change-operations.json" ]; then
    __sending=1
    cp /app/.eth/ethdo/change-operations.json /app
    chown ethdo:ethdo /app/change-operations.json
    __address=$(jq -r .[0].message.to_execution_address < /app/change-operations.json)
    __count=$(jq '. | length' < /app/change-operations.json)
    echo "You are about to change the withdrawal address of ${__count} validators to Ethereum address ${__address}"
    echo "Please make TRIPLY sure that you control this address."
    echo
    read -rp "I have verified that I control ${__address}, change the withdrawal address (No/Yes): " yn
    case $yn in
      [Yy][Ee][Ss] ) ;;
      * ) echo "Aborting"; exit 0;;
    esac
  else
    echo "No change-operations.json found in ./.eth/ethdo. Aborting."
    exit 0
  fi
fi

gosu ethdo "${ARGS[@]}"
__result=$?
if [ "${__sending}" -eq 1 ]; then
  if [ "${__result}" -eq 0 ]; then
    echo "Change sent successfully"
  else
    # We actually won't get to here because of the set -e, but just in case
    echo "Something went wrong when sending the change, error code ${__result}"
  fi
fi

if [[ "$@" =~ "--prepare-offline" ]]; then
  if [ "${NETWORK}" = "mainnet" ]; then
    __butta="https://beaconcha.in"
  else
    __butta="https://${NETWORK}.beaconcha.in"
  fi
  cp -rp /app/offline-preparation.json /app/.eth/ethdo/
  chown "$uid":"$uid" /app/.eth/ethdo/offline-preparation.json
  echo "The preparation file has been copied to ./.eth/ethdo/offline-preparation.json"
  echo "It contains $(jq .validators[].index </app/.eth/ethdo/offline-preparation.json | wc -l) validators."
  echo "Please verify that this matches what you see on ${__butta}/validators"
fi
