#!/bin/bash

if [ -f /keymanagertoken/token ]; then
  cp /keymanagertoken/token /var/lib/nimbus/token
else
  if [ ! -f /var/lib/nimbus/token ]; then
      echo "notoken" > /var/lib/nimbus/token
  fi
fi

exec "$@"
