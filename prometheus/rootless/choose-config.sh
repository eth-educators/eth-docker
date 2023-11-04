#!/bin/sh
# Stitch together a prometheus.yml, for rootless mode
# Expects a full prometheus command with parameters as argument(s)

# Start fresh every time
cp /etc/prometheus/rootless/global.yml /etc/prometheus/prometheus.yml

case "$CLIENT" in
  *lighthouse.yml* )  cat /etc/prometheus/rootless/lh-prom.yml  >> /etc/prometheus/prometheus.yml;;
  *lighthouse-cl-only* ) cat /etc/prometheus/rootless/lhcc-prom.yml >> /etc/prometheus/prometheus.yml;;
  *prysm.yml* ) cat /etc/prometheus/rootless/prysm-prom.yml >> /etc/prometheus/prometheus.yml;;
  *prysm-cl-only* ) cat /etc/prometheus/rootless/prysmcc-prom.yml >> /etc/prometheus/prometheus.yml;;
  *nimbus.yml* ) cat /etc/prometheus/rootless/nimbus-prom.yml >> /etc/prometheus/prometheus.yml;;
  *nimbus-cl-only* ) cat /etc/prometheus/rootless/nimbus-prom.yml >> /etc/prometheus/prometheus.yml;;
  *teku.yml* ) cat /etc/prometheus/rootless/teku-prom.yml >> /etc/prometheus/prometheus.yml;;
  *teku-cl-only* ) cat /etc/prometheus/rootless/teku-prom.yml >> /etc/prometheus/prometheus.yml;;
  *lodestar.yml* ) cat /etc/prometheus/rootless/ls-prom.yml >> /etc/prometheus/prometheus.yml;;
  *lodestar-cl-only* ) cat /etc/prometheus/rootless/lscc-prom.yml >> /etc/prometheus/prometheus.yml;;
  * ) ;;
esac

case "$CLIENT" in
  *geth* ) cat /etc/prometheus/rootless/geth-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *erigon* ) cat /etc/prometheus/rootless/erigon-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *besu* ) cat /etc/prometheus/rootless/besu-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *nethermind* ) cat /etc/prometheus/rootless/nethermind-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *reth* ) cat /etc/prometheus/rootless/reth-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *web3signer.yml* ) cat /etc/prometheus/rootless/web3signer-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *ssv.yml* ) cat /etc/prometheus/rootless/ssv-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *traefik-* ) cat /etc/prometheus/rootless/traefik-prom.yml >> /etc/prometheus/prometheus.yml;;
esac

if [ -f "/etc/prometheus/custom-prom.yml" ]; then
    cat /etc/prometheus/custom-prom.yml >> /etc/prometheus/prometheus.yml
fi

exec "$@" --config.file=/etc/prometheus/prometheus.yml
