#!/bin/sh
# Avoid needing multiple grafana.yml files by checking CLIENT, which is COMPOSE_FILE, for the
# Prometheus config we need.
# Expects a full prometheus command with parameters as argument(s)

case "$CLIENT" in
  *lh-base* ) conffile=lh-prom.yml ;;
  *prysm-base* ) conffile=prysm-prom.yml ;;
  *nimbus-base* ) conffile=nimbus-prom.yml ;;
  *teku-base* ) conffile=teku-prom.yml ;;
  * ) conffile=none.yml ;;
esac

cp /etc/prometheus/$conffile /etc/prometheus/prometheus.yml

case "$CLIENT" in
  *geth* ) cat /etc/prometheus/geth-prom.yml >> /etc/prometheus/prometheus.yml ;;
  *erigon* ) cat /etc/prometheus/erigon-prom.yml >> /etc/prometheus/prometheus.yml ;;
esac

"$@" --config.file=/etc/prometheus/prometheus.yml
