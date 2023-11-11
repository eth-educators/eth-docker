#!/bin/sh
# Stitch together a Prometheus config for rootless mode

# Start fresh every time
cp rootless-base-config.yml rootless-with-clients.yml

case "$CLIENT" in
  *lighthouse.yml* )  cat ./rootless/lh-prom.yml  >> ./rootless-with-clients.yml ;;
  *lighthouse-cl-only* ) cat ./rootless/lhcc-prom.yml >> ./rootless-with-clients.yml ;;
  *prysm.yml* ) cat ./rootless/prysm-prom.yml >> ./rootless-with-clients.yml ;;
  *prysm-cl-only* ) cat ./rootless/prysmcc-prom.yml >> ./rootless-with-clients.yml ;;
  *nimbus.yml* ) cat ./rootless/nimbus-prom.yml >> ./rootless-with-clients.yml ;;
  *nimbus-cl-only* ) cat ./rootless/nimbus-prom.yml >> ./rootless-with-clients.yml ;;
  *teku.yml* ) cat ./rootless/teku-prom.yml >> ./rootless-with-clients.yml ;;
  *teku-cl-only* ) cat ./rootless/teku-prom.yml >> ./rootless-with-clients.yml ;;
  *lodestar.yml* ) cat ./rootless/ls-prom.yml >> ./rootless-with-clients.yml ;;
  *lodestar-cl-only* ) cat ./rootless/lscc-prom.yml >> ./rootless-with-clients.yml ;;
  * ) ;;
esac

case "$CLIENT" in
  *geth* ) cat ./rootless/geth-prom.yml >> ./rootless-with-clients.yml ;;
  *erigon* ) cat ./rootless/erigon-prom.yml >> ./rootless-with-clients.yml ;;
  *besu* ) cat ./rootless/besu-prom.yml >> ./rootless-with-clients.yml ;;
  *nethermind* ) cat ./rootless/nethermind-prom.yml >> ./rootless-with-clients.yml ;;
  *reth* ) cat ./rootless/reth-prom.yml >> ./rootless-with-clients.yml ;;
esac

case "$CLIENT" in
  *web3signer.yml* ) cat ./rootless/web3signer-prom.yml >> ./rootless-with-clients.yml ;;
esac

case "$CLIENT" in
  *ssv.yml* ) cat ./rootless/ssv-prom.yml >> ./rootless-with-clients.yml ;;
esac

case "$CLIENT" in
  *traefik-* ) cat ./rootless/traefik-prom.yml >> ./rootless-with-clients.yml ;;
esac
