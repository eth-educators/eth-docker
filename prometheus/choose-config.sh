#!/bin/sh
# Avoid needing multiple grafana.yml files by checking CLIENT, which is COMPOSE_FILE, for the
# Prometheus config we need.
# Expects a full prometheus command with parameters as argument(s)

case "$CLIENT" in
  *lighthouse.yml* ) conffile=lh-prom.yml ;;
  *lighthouse-cl-only* ) conffile=lhcc-prom.yml ;;
  *prysm.yml* ) conffile=prysm-prom.yml ;;
  *prysm-cl-only* ) conffile=prysmcc-prom.yml ;;
  *nimbus.yml* ) conffile=nimbus-prom.yml ;;
  *nimbus-cl-only* ) conffile=nimbus-prom.yml ;;
  *teku.yml* ) conffile=teku-prom.yml ;;
  *teku-cl-only* ) conffile=teku-prom.yml ;;
  *lodestar.yml* ) conffile=ls-prom.yml ;;
  *lodestar-cl-only* ) conffile=lscc-prom.yml ;;
  * ) conffile=none.yml ;;
esac

cp /etc/prometheus/$conffile /etc/prometheus/prometheus.yml

case "$CLIENT" in
  *geth* ) cat /etc/prometheus/geth-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *erigon* ) cat /etc/prometheus/erigon-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *besu* ) cat /etc/prometheus/besu-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *nethermind* ) cat /etc/prometheus/nethermind-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *blox-ssv2* ) cat /etc/prometheus/blox-ssv2-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *blox-ssv* ) cat /etc/prometheus/blox-ssv-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

case "$CLIENT" in
  *traefik-* ) cat /etc/prometheus/traefik-prom.yml >> /etc/prometheus/prometheus.yml;;
esac

exec "$@" --config.file=/etc/prometheus/prometheus.yml
