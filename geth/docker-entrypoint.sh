#!/usr/bin/env sh
if [ -f /var/lib/goethereum/prune-marker ]; then
  $@ snapshot prune-state
  rm -f /var/lib/goethereum/prune-marker
else
  exec $@
fi
