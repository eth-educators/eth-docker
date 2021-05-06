#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run lighthouse as lhbeacon or lhvalidator, depending 
if [ "$(id -u)" = '0' ]; then
  if [[ "$2" =~ ^(beacon_node|beacon|bn|b)$ ]]; then
    chown -R lhbeacon:lhbeacon /var/lib/lighthouse
    exec gosu lhbeacon "$BASH_SOURCE" "$@"
  elif [[ "$2" =~ ^(validator_client|validator|vc|v)$ ]]; then
    chown -R lhvalidator:lhvalidator /var/lib/lighthouse
    exec gosu lhvalidator "$BASH_SOURCE" "$@"
  else
    echo "Could not determine whether beacon or validator client."
    echo "This is a bug, please report it at https://github.com/eth2-educators/eth2-docker/,"
    echo "and thank you."
    echo "Failed to match on" $2
    exit
  fi
fi

exec "$@"
