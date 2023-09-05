#!/bin/bash
# Provision dashboards for chosen client. This may not work too well if clients are changed
# without deleting the grafana docker volume
# Expects a full grafana command with parameters as argument(s)

if [ "$(id -u)" = '0' ]; then
  chown -R grafana:root /var/lib/grafana
  chown -R grafana:root /etc/grafana
  exec su-exec grafana "$0" "$@"
fi

case "$CLIENT" in
  *prysm* )
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "prysm_metanull"' >"${__file}"
    #  prysm_small
    __url='https://docs.prylabs.network/assets/grafana-dashboards/small_amount_validators.json'
    __file='/etc/grafana/provisioning/dashboards/prysm_small.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Prysm Dashboard"' >"${__file}"
    #  prysm_more_10
    __url='https://docs.prylabs.network/assets/grafana-dashboards/big_amount_validators.json'
    __file='/etc/grafana/provisioning/dashboards/prysm_big.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Prysm Dashboard Many Validators"' >"${__file}"
    ;;&
  *lighthouse* )
    #  lighthouse_summary
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_summary.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "lighthouse_summary"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    #  lighthouse_validator_client
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_validator_client.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "lighthouse_validator_client"' >"${__file}"
    # lighthouse_validator_monitor
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorMonitor.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_validator_monitor.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "lighthouse_validator_monitor"' >"${__file}"
    ;;&
  *teku* )
    #  teku_overview
    __url='https://grafana.com/api/dashboards/12199/revisions/1/download'
    __file='/etc/grafana/provisioning/dashboards/teku_overview.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "teku_overview"' >"${__file}"
    ;;&
  *nimbus* )
    #  nimbus_dashboard
    __url='https://raw.githubusercontent.com/status-im/nimbus-eth2/master/grafana/beacon_nodes_Grafana_dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/nimbus_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "nimbus_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"{$__file}"
    ;;&
  *lodestar* )
    #  lodestar summary
    __url='https://raw.githubusercontent.com/ChainSafe/lodestar/stable/dashboards/lodestar_summary.json'
    __file='/etc/grafana/provisioning/dashboards/lodestar_summary.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "lodestar_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' | \
        jq 'walk(if . == "prometheus_local" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *geth* )
    # geth_dashboard
    __url='https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/geth_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "geth_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *erigon* )
    # erigon_dashboard
    __url='https://raw.githubusercontent.com/ledgerwatch/erigon/devel/cmd/prometheus/dashboards/erigon.json'
    __file='/etc/grafana/provisioning/dashboards/erigon_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "erigon_dashboard"' | jq '.uid = "YbLNLr6Mz"' >"${__file}"
    ;;&
  *besu* )
    # besu_dashboard
    __url='https://grafana.com/api/dashboards/10273/revisions/5/download'
    __file='/etc/grafana/provisioning/dashboards/besu_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "besu_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *reth* )
    # reth_dashboard
    __url='https://raw.githubusercontent.com/paradigmxyz/reth/main/etc/grafana/dashboards/overview.json'
    __file='/etc/grafana/provisioning/dashboards/reth_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "reth_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *nethermind* )
    # nethermind_dashboard
    __url='https://raw.githubusercontent.com/NethermindEth/metrics-infrastructure/master/grafana/provisioning/dashboards/nethermind.json'
    __file='/etc/grafana/provisioning/dashboards/nethermind_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "prometheus_ds" then "Prometheus" else . end)' >"${__file}"
#    cp /tmp/nethermind_dashboard.json "${__file}"
    ;;&
  *ssv.yml* )
    # SSV Operator Dashboard
    __url='https://raw.githubusercontent.com/bloxapp/ssv/main/monitoring/grafana/dashboard_ssv_operator_performance.json'
    __file='/etc/grafana/provisioning/dashboards/ssv_operator_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.templating.list[0].current |= {selected: false, text: "ssv-node", value: "ssv-node"} | .templating.list[0].options = [ { "selected": true, "text": "ssv-node", "value": "ssv-node" } ] | .templating.list[0].query = "ssv-node"' >"${__file}"
    __url='https://raw.githubusercontent.com/bloxapp/ssv/main/monitoring/grafana/dashboard_ssv_node.json'
    __file='/etc/grafana/provisioning/dashboards/ssv_node_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.templating.list[0].current |= {selected: false, text: "ssv-node", value: "ssv-node"} | .templating.list[0].options = [ { "selected": true, "text": "ssv-node", "value": "ssv-node" } ] | .templating.list[0].query = "ssv-node"' >"${__file}"
    ;;&
  * )
    # Home staking dashboard
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/17846 | jq .revision)
    __url="https://grafana.com/api/dashboards/17846/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/homestaking-dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    # Ethereum Metrics Exporter Dashboard
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/16277 | jq .revision)
    __url="https://grafana.com/api/dashboards/16277/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/ethereum-metrics-exporter-single.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    # cadvisor and node exporter dashboard
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/10619 | jq .revision)
    __url="https://grafana.com/api/dashboards/10619/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/docker-host-container-overview.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    # Log file dashboard (via loki)
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/18700 | jq .revision)
    __url="https://grafana.com/api/dashboards/18700/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/eth-docker-logs.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_LOKI}" then "Loki" else . end)' >"${__file}"
    ;;
esac

# Remove empty files, so a download error doesn't kill Grafana
find /etc/grafana/provisioning -type f -empty -delete

tree /etc/grafana/provisioning/

exec "$@"
