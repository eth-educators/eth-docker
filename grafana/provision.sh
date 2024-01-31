#!/bin/bash
# Provision dashboards for chosen client. This may not work too well if clients are changed
# without deleting the grafana docker volume
# Expects a full grafana command with parameters as argument(s)

if [ "$(id -u)" = '0' ]; then
  chown -R grafana:root /var/lib/grafana
  chown -R grafana:root /etc/grafana
  exec su-exec grafana "$0" "$@"
fi

cp /tmp/grafana/provisioning/alerting/* /etc/grafana/provisioning/alerting/

shopt -s extglob
case "$CLIENT" in
  *prysm* )
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
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Lighthouse Summary"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    #  lighthouse_validator_client
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_validator_client.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Lighthouse Validator Client"' >"${__file}"
    # lighthouse_validator_monitor
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorMonitor.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_validator_monitor.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Lighthouse Validator Monitor"' >"${__file}"
    ;;&
  *teku* )
    #  teku_overview
    __id=12199
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
    __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/teku_overview.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Teku Overview"' >"${__file}"
    ;;&
  *nimbus* )
    #  nimbus_dashboard
    __url='https://raw.githubusercontent.com/status-im/nimbus-eth2/master/grafana/beacon_nodes_Grafana_dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/nimbus_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Nimbus Dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS-PROXY}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *lodestar* )
    #  lodestar summary
    __url='https://raw.githubusercontent.com/ChainSafe/lodestar/stable/dashboards/lodestar_summary.json'
    __file='/etc/grafana/provisioning/dashboards/lodestar_summary.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Lodestar Dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' | \
        jq 'walk(if . == "prometheus_local" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *geth* )
    # geth_dashboard
    __url='https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/geth_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Geth Dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *erigon* )
    # erigon_dashboard
    __url='https://raw.githubusercontent.com/ledgerwatch/erigon/devel/cmd/prometheus/dashboards/erigon.json'
    __file='/etc/grafana/provisioning/dashboards/erigon_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Erigon Dashboard"' | jq '.uid = "YbLNLr6Mz"' >"${__file}"
    ;;&
  *besu* )
    # besu_dashboard
    __id=10273
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
    __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/besu_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Besu Dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *reth* )
    # reth_dashboard
    __url='https://raw.githubusercontent.com/paradigmxyz/reth/main/etc/grafana/dashboards/overview.json'
    __file='/etc/grafana/provisioning/dashboards/reth_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "Reth Dashboard"' \
        | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *nethermind* )
    # nethermind_dashboard
    __url='https://raw.githubusercontent.com/NethermindEth/metrics-infrastructure/master/grafana/provisioning/dashboards/nethermind.json'
    __file='/etc/grafana/provisioning/dashboards/nethermind_dashboardv2.json'
    wget -t 3 -T 10 -qcO - "${__url}" >"${__file}"
    # uid changed, removing this may undo the damage
    if [ -f "/etc/grafana/provisioning/dashboards/nethermind_dashboard.json" ]; then
      rm "/etc/grafana/provisioning/dashboards/nethermind_dashboard.json"
    fi
    ;;&
  *web3signer* )
    # web3signer_dashboard
    __id=13687
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
    __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/web3signer.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;&
  *ssv.yml* )
    # SSV Operator Dashboard
    __url='https://raw.githubusercontent.com/bloxapp/ssv/main/monitoring/grafana/dashboard_ssv_operator_performance.json'
    __file='/etc/grafana/provisioning/dashboards/ssv_operator_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "SSV Operator Performance Dashboard"' \
        | jq '.templating.list[0].current |= {selected: false, text: "ssv-node", value: "ssv-node"} | .templating.list[0].options = [ { "selected": true, "text": "ssv-node", "value": "ssv-node" } ] | .templating.list[0].query = "ssv-node"' \
        | sed 's/eXfXfqH7z/Prometheus/g' >"${__file}"
    __url='https://raw.githubusercontent.com/bloxapp/ssv/main/monitoring/grafana/dashboard_ssv_node.json'
    __file='/etc/grafana/provisioning/dashboards/ssv_node_dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq '.title = "SSV Node Dashboard"' \
        | jq '.templating.list[0].current |= {selected: false, text: "ssv-node", value: "ssv-node"} | .templating.list[0].options = [ { "selected": true, "text": "ssv-node", "value": "ssv-node" } ] | .templating.list[0].query = "ssv-node"' \
        | sed 's/eXfXfqH7z/Prometheus/g' >"${__file}"
    ;;&
  !(*grafana-rootless*) )
      # cadvisor and node exporter dashboard
      __id=10619
      __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
      __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
      __file='/etc/grafana/provisioning/dashboards/docker-host-container-overview.json'
      wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
      # Log file dashboard (via loki)
      __id=20223
      __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
      __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
      __file='/etc/grafana/provisioning/dashboards/eth-docker-logs.json'
      wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_LOKI}" then "Loki" else . end)' >"${__file}"
    ;;&
  * )
    # Home staking dashboard
    __id=17846
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
    __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/homestaking-dashboard.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    # Ethereum Metrics Exporter Dashboard
    __id=16277
    __revision=$(wget -t 3 -T 10 -qO - https://grafana.com/api/dashboards/${__id} | jq .revision)
    __url="https://grafana.com/api/dashboards/${__id}/revisions/${__revision}/download"
    __file='/etc/grafana/provisioning/dashboards/ethereum-metrics-exporter-single.json'
    wget -t 3 -T 10 -qcO - "${__url}" | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >"${__file}"
    ;;
esac

# Remove empty files, so a download error doesn't kill Grafana
find /etc/grafana/provisioning -type f -empty -delete

tree /etc/grafana/provisioning/

exec "$@"
