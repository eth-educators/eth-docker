#!/bin/sh
# Avoid needing multiple grafana.yml files by checking CLIENT, which is COMPOSE_FILE, for the
# Prometheus config we need.
# Expects a full prometheus command with parameters as argument(s)

# Start fresh every time
cp /etc/prometheus/global.yml /etc/prometheus/prometheus.yml

case "$CLIENT" in
  *lighthouse.yml* )  cat /etc/prometheus/lh-prom.yml  >> /etc/prometheus/prometheus.yml;;
  *lighthouse-cl-only* ) cat /etc/prometheus/lhcc-prom.yml >> /etc/prometheus/prometheus.yml;;
  *prysm.yml* ) cat /etc/prometheus/prysm-prom.yml >> /etc/prometheus/prometheus.yml;;
  *prysm-cl-only* ) cat /etc/prometheus/prysmcc-prom.yml >> /etc/prometheus/prometheus.yml;;
  *nimbus.yml* ) cat /etc/prometheus/nimbus-prom.yml >> /etc/prometheus/prometheus.yml;;
  *nimbus-cl-only* ) cat /etc/prometheus/nimbus-prom.yml >> /etc/prometheus/prometheus.yml;;
  *teku.yml* ) cat /etc/prometheus/teku-prom.yml >> /etc/prometheus/prometheus.yml;;
  *teku-cl-only* ) cat /etc/prometheus/teku-prom.yml >> /etc/prometheus/prometheus.yml;;
  *lodestar.yml* ) cat /etc/prometheus/ls-prom.yml >> /etc/prometheus/prometheus.yml;;
  *lodestar-cl-only* ) cat /etc/prometheus/lscc-prom.yml >> /etc/prometheus/prometheus.yml;;
  * ) ;;
esac

case "$CLIENT" in
  *geth* ) cat /etc/prometheus/geth-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *erigon* ) cat /etc/prometheus/erigon-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *besu* ) cat /etc/prometheus/besu-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *nethermind* ) cat /etc/prometheus/nethermind-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *reth* ) cat /etc/prometheus/reth-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *web3signer.yml* ) cat /etc/prometheus/web3signer-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *ssv.yml* ) cat /etc/prometheus/ssv-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *traefik-* ) cat /etc/prometheus/traefik-prom.yml >> /etc/prometheus/prometheus.yml;;
esac

if [ -f "/etc/prometheus/custom-prom.yml" ]; then
    cat /etc/prometheus/custom-prom.yml >> /etc/prometheus/prometheus.yml
fi

exec "$@" --config.file=/etc/prometheus/prometheus.yml
