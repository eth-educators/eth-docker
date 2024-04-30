#!/usr/bin/env bash

__consensus=""
__execution=""

case "$CLIENT" in
    *lighthouse* | *prysm* | *nimbus* | *teku* | *lodestar* | *grandine* ) __consensus="--consensus-url=http://consensus:5052" ;;&
    *geth* | *besu* | *nethermind* | *erigon* | *reth* ) __execution="--execution-url=http://execution:8545" ;;
esac

exec "$@" $__consensus $__execution
