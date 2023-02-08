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

gosu ethdo "${ARGS[@]}"

if [[ "$@" =~ "--prepare-offline" ]]; then
  cp -rp /app/offline-preparation.json /app/.eth/ethdo/
  chown "$uid":"$uid" /app/.eth/ethdo/offline-preparation.json
  echo "The preparation file has been copied to ./.eth/ethdo/offline-preparation.json"
  echo "It contains $(jq .validators[].index </app/.eth/ethdo/offline-preparation.json | wc -l) validators."
  echo "Please verify that this matches what you see on https://beaconcha.in"
fi
