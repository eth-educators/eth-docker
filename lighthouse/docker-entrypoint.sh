#!/usr/bin/env bash
if [ "${MEV_BOOST}" = "true" ]; then
  echo "MEV Boost enabled"
  exec $@ --builder http://mev-boost:18550
else
  exec $@
fi
