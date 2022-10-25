#!/bin/bash
# Provision dashboards for chosen client. This may not work too well if clients are changed
# without deleting the grafana docker volume
# Expects a full grafana command with parameters as argument(s)

case "$CLIENT" in
  *prysm* )
    #  prysm_metanull
    __url='https://raw.githubusercontent.com/metanull-operator/eth2-grafana/master/eth2-grafana-dashboard-single-source-beacon_node.json'
    __file='/etc/grafana/provisioning/dashboards/prysm_metanull.json'
    wget -qcO - $__url | jq '.title = "prysm_metanull"' >$__file
    #  prysm_less_10
    __url='https://raw.githubusercontent.com/GuillaumeMiralles/prysm-grafana-dashboard/master/less_10_validators.json'
    __file='/etc/grafana/provisioning/dashboards/prysm_less_10.json'
    wget -qcO - $__url | jq '.title = "prysm_less_10"' >$__file
    #  prysm_more_10
    __url='https://raw.githubusercontent.com/GuillaumeMiralles/prysm-grafana-dashboard/master/more_10_validators.json'
    __file='/etc/grafana/provisioning/dashboards/prysm_more_10.json'
    wget -qcO - $__url | jq '.title = "prysm_more_10"' >$__file
    # prysm_ynager
    __url='https://raw.githubusercontent.com/ynager/grafana-eth-staking/main/dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/prysm_ynager.json'
    wget -qcO - $__url | jq '.title = "prysm_ynager"' >$__file
    ;;&
  *lighthouse* )
    #  lighthouse_summary
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_summary.json'
    wget -qcO - $__url | jq '.title = "lighthouse_summary"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    #  lighthouse_validator_client
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_validator_client.json'
    wget -qcO - $__url | jq '.title = "lighthouse_validator_client"' >$__file
    # lighthouse_validator_monitor
    __url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorMonitor.json'
    __file='/etc/grafana/provisioning/dashboards/lighthouse_validator_monitor.json'
    wget -qcO - $__url | jq '.title = "lighthouse_validator_monitor"' >$__file
    # lighthouse_yoldark34
    # This needs a bit more for datasource than is here
    #__url='https://raw.githubusercontent.com/Yoldark34/lighthouse-staking-dashboard/main/Yoldark_ETH_staking_dashboard.json'
    #__file='/etc/grafana/provisioning/dashboards/lighthouse_yoldark34.json'
    #wget -qcO - $__url | jq '.title = "lighthouse_yoldark34"' | jq '.uid = "t2yHaa3Zz3lou"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    ;;&
  *teku* )
    #  teku_overview
    __url='https://grafana.com/api/dashboards/12199/revisions/1/download'
    __file='/etc/grafana/provisioning/dashboards/teku_overview.json'
    wget -qcO - $__url | jq '.title = "teku_overview"' >$__file
    ;;&
  *nimbus* )
    #  nimbus_dashboard
    __url='https://raw.githubusercontent.com/status-im/nimbus-eth2/master/grafana/beacon_nodes_Grafana_dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/nimbus_dashboard.json'
    wget -qcO - $__url | jq '.title = "nimbus_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    ;;&
  *lodestar* )
    #  lodestar summary
    __url='https://raw.githubusercontent.com/ChainSafe/lodestar/stable/dashboards/lodestar_summary.json'
    __file='/etc/grafana/provisioning/dashboards/lodestar_summary.json'
    wget -qcO - $__url | jq '.title = "lodestar_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' | \
        jq 'walk(if . == "prometheus_local" then "Prometheus" else . end)' >$__file
    ;;&
  *geth* )
    # geth_dashboard
    __url='https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json'
    __file='/etc/grafana/provisioning/dashboards/geth_dashboard.json'
    wget -qcO - $__url | jq '.title = "geth_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    ;;&
  *erigon* )
    # erigon_dashboard
    __url='https://raw.githubusercontent.com/ledgerwatch/erigon/devel/cmd/prometheus/dashboards/erigon.json'
    __file='/etc/grafana/provisioning/dashboards/erigon_dashboard.json'
    wget -qcO - $__url | jq '.title = "erigon_dashboard"' | jq '.uid = "YbLNLr6Mz"' >$__file
    ;;&
  *besu* )
    # besu_dashboard
    __url='https://grafana.com/api/dashboards/10273/revisions/5/download'
    __file='/etc/grafana/provisioning/dashboards/besu_dashboard.json'
    wget -qcO - $__url | jq '.title = "besu_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    ;;&
  *nethermind* )
    # nethermind_dashboard
#    __url='https://raw.githubusercontent.com/NethermindEth/metrics-infrastructure/master/grafana/dashboards/nethermind.json'
    __file='/etc/grafana/provisioning/dashboards/nethermind_dashboard.json'
#    wget -qcO - $__url | jq '.title = "nethermind_dashboard"' >$__file
    cp /tmp/nethermind_dashboard.json $__file
    ;;&
  *blox-ssv* )
    # Blox SSV Operator Dashboard
    __url='https://raw.githubusercontent.com/bloxapp/ssv/main/monitoring/grafana/dashboard_ssv_operator.json'
    __file='/etc/grafana/provisioning/dashboards/blox_ssv_operator_dashboard.json'
    wget -qcO - $__url | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    __url='https://raw.githubusercontent.com/bloxapp/ssv/main/monitoring/grafana/dashboard_ssv_validator.json'
    __file='/etc/grafana/provisioning/dashboards/blox_ssv_validator_dashboard.json'
    wget -qcO - $__url | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    ;;&
  * )
    # Ethereum Metrics Exporter Dashboard
    __url='https://grafana.com/api/dashboards/16277/revisions/13/download'
    __file='/etc/grafana/provisioning/dashboards/ethereum-metrics-exporter-single.json'
    wget -qcO - $__url | jq 'walk(if . == "${DS_VICTORIAMETRICS}" then "Prometheus" else . end)' >$__file
    # cadvisor and node exporter dashboard
    __url='https://grafana.com/api/dashboards/10619/revisions/1/download'
    __file='/etc/grafana/provisioning/dashboards/docker-host-container-overview.json'
    wget -qcO - $__url | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$__file
    ;;
esac

tree /etc/grafana/provisioning/

exec "$@"
