#!/bin/sh

set -eu

select_clients() {
  mkdir -p /etc/prometheus/rootless.d

  case "$CLIENT" in
    *lighthouse.yml* )  cp ./rootless/lh-prom.yml /etc/prometheus/rootless.d ;;
    *lighthouse-cl-only* ) cp ./rootless/lhcc-prom.yml /etc/prometheus/rootless.d ;;
    *prysm.yml* ) cp ./rootless/prysm-prom.yml /etc/prometheus/rootless.d ;;
    *prysm-cl-only* ) cp ./rootless/prysmcc-prom.yml /etc/prometheus/rootless.d ;;
    *nimbus.yml* ) cp ./rootless/nimbus-prom.yml /etc/prometheus/rootless.d ;;
    *nimbus-cl-only* ) cp ./rootless/nimbus-prom.yml /etc/prometheus/rootless.d ;;
    *teku.yml* ) cp ./rootless/teku-prom.yml /etc/prometheus/rootless.d ;;
    *teku-cl-only* ) cp ./rootless/teku-prom.yml /etc/prometheus/rootless.d ;;
    *lodestar.yml* ) cp ./rootless/ls-prom.yml /etc/prometheus/rootless.d ;;
    *lodestar-cl-only* ) cp ./rootless/lscc-prom.yml /etc/prometheus/rootless.d ;;
    * ) ;;
  esac

  case "$CLIENT" in
    *geth* ) cp ./rootless/geth-prom.yml /etc/prometheus/rootless.d ;;
    *erigon* ) cp ./rootless/erigon-prom.yml /etc/prometheus/rootless.d ;;
    *besu* ) cp ./rootless/besu-prom.yml /etc/prometheus/rootless.d ;;
    *nethermind* ) cp ./rootless/nethermind-prom.yml /etc/prometheus/rootless.d ;;
    *reth* ) cp ./rootless/reth-prom.yml /etc/prometheus/rootless.d ;;
  esac

  case "$CLIENT" in
    *web3signer.yml* ) cp ./rootless/web3signer-prom.yml /etc/prometheus/rootless.d ;;
  esac

  case "$CLIENT" in
    *ssv.yml* ) cp ./rootless/ssv-prom.yml /etc/prometheus/rootless.d ;;
  esac

  case "$CLIENT" in
    *traefik-* ) cp ./rootless/traefik-prom.yml /etc/prometheus/rootless.d ;;
  esac

  __num_files="$(find /etc/prometheus/rootless.d -type f | wc -l)"
  if [ "$__num_files" -gt 0 ]; then
    echo "Activated $__num_files configuration files"
  else
    echo "No Prometheus configurations have been enabled based on the provided CLIENT variable"
  fi
}

# CLIENT is only set for rootless mode
if [ -z "${CLIENT:-}" ]; then
  echo "No Client information passed, running in Docker target detection mode"
  if [ -s custom-prom.yml ]; then
    echo "Applying custom configuration"
    # $item isn't a shell variable, single quotes OK here
    # shellcheck disable=SC2016
    yq eval-all '. as $item ireduce ({}; . *+ $item)' base-config.yml custom-prom.yml > /etc/prometheus/prometheus.yml
  else
    echo "No custom configuration detected"
    cp base-config.yml /etc/prometheus/prometheus.yml
  fi
else
  echo "Client information detected, compiling prometheus config"
  select_clients
  if [ -s custom-prom.yml ]; then
    echo "Applying custom configuration"
    # $item isn't a shell variable, single quotes OK here
    # shellcheck disable=SC2016
    yq eval-all '. as $item ireduce ({}; . *+ $item)' rootless-base-config.yml custom-prom.yml > /etc/prometheus/prometheus.yml
  else
    echo "No custom configuration detected"
    cp rootless-base-config.yml /etc/prometheus/prometheus.yml
  fi
fi

/bin/prometheus "$@" --config.file=/etc/prometheus/prometheus.yml