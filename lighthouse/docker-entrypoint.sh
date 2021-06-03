#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run lighthouse as lhconsensus or lhvalidator, depending 
if [ "$(id -u)" = '0' ]; then
  if [[ "$2" =~ ^(beacon_node|beacon|bn|b)$ ]]; then
    chown -R lhconsensus:lhconsensus /var/lib/lighthouse
    exec gosu lhconsensus "$BASH_SOURCE" "$@"
  elif [[ "$2" =~ ^(validator_client|validator|vc|v)$ ]]; then
    chown -R lhvalidator:lhvalidator /var/lib/lighthouse
    exec gosu lhvalidator "$BASH_SOURCE" "$@"
  else
    echo "Could not determine whether consensus or validator client, running as-is."
  fi
fi

exec "$@"
