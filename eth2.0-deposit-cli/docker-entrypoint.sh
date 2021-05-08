#!/bin/bash
set -Eeuo pipefail

# This will be started as root, so the generated files can be copied when done

# Find --uid if it exists, parse and discard. Used to chown after.
# Ditto --folder, since this now copies we need to parse it out
ARGS=()
foundu=0
foundf=0
uid=1000
folder="validator_keys"
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
    foundf=1
    folder="$var"
    continue
  fi
  ARGS+=("$var")
done

su-exec depcli "${ARGS[@]}"

mkdir -p /app/.eth2/"$folder"
cp -p /app/validator_keys/* /app/.eth2/"$folder"/

chown -R "$uid":"$uid" /app/.eth2/"$folder"

echo "The generated files have been copied to ./.eth2/$folder/"
