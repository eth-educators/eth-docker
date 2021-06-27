FROM grafana/grafana

USER root
RUN apk add wget
RUN apk add tree
RUN apk add jq
RUN apk add sed

RUN mkdir -p /etc/grafana/provisioning/dashboards/
RUN mkdir -p /etc/grafana/provisioning/datasources/
COPY ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY ./datasource.yml /etc/grafana/provisioning/datasources/

#  prysm_metanull
ARG prysm_metanull_url='https://raw.githubusercontent.com/metanull-operator/eth2-grafana/master/eth2-grafana-dashboard-single-source-beacon_node.json'
ARG prysm_metanull_file='/etc/grafana/provisioning/dashboards/prysm_metanull.json'
RUN wget -qcO - $prysm_metanull_url | jq '.title = "prysm_metanull"' >$prysm_metanull_file

#  prysm_less_10
ARG prysm_less_10_url='https://raw.githubusercontent.com/GuillaumeMiralles/prysm-grafana-dashboard/master/less_10_validators.json'
ARG prysm_less_10_file='/etc/grafana/provisioning/dashboards/prysm_less_10.json'
RUN wget -qcO - $prysm_less_10_url | jq '.title = "prysm_less_10"' >$prysm_less_10_file

#  prysm_more_10
ARG prysm_more_10_url='https://raw.githubusercontent.com/GuillaumeMiralles/prysm-grafana-dashboard/master/more_10_validators.json'
ARG prysm_more_10_file='/etc/grafana/provisioning/dashboards/prysm_more_10.json'
RUN wget -qcO - $prysm_more_10_url | jq '.title = "prysm_more_10"' >$prysm_more_10_file

# prysm_ynager
ARG prysm_ynager_url='https://raw.githubusercontent.com/ynager/grafana-eth-staking/main/dashboard.json'
ARG prysm_ynager_file='/etc/grafana/provisioning/dashboards/prysm_ynager.json'
RUN wget -qcO - $prysm_ynager_url | jq '.title = "prysm_ynager"' >$prysm_ynager_file

#  lighthouse_summary
ARG lighthouse_summary_url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json'
ARG lighthouse_summary_file='/etc/grafana/provisioning/dashboards/lighthouse_summary.json'
RUN wget -qcO - $lighthouse_summary_url | jq '.title = "lighthouse_summary"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$lighthouse_summary_file

#  lighthouse_validator_client

ARG lighthouse_validator_client_url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json'
ARG lighthouse_validator_client_file='/etc/grafana/provisioning/dashboards/lighthouse_validator_client.json'
RUN wget -qcO - $lighthouse_validator_client_url | jq '.title = "lighthouse_validator_client"' >$lighthouse_validator_client_file

# lighthouse_validator_monitor
ARG lighthouse_validator_monitor_url='https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorMonitor.json'
ARG lighthouse_validator_monitor_file='/etc/grafana/provisioning/dashboards/lighthouse_validator_monitor.json'
RUN wget -qcO - $lighthouse_validator_monitor_url | jq '.title = "lighthouse_validator_monitor"' >$lighthouse_validator_monitor_file

# lighthouse_yoldark34
ARG lighthouse_yoldark34_url='https://raw.githubusercontent.com/Yoldark34/lighthouse-staking-dashboard/main/Yoldark_ETH_staking_dashboard.json'
ARG lighthouse_yoldark34_file='/etc/grafana/provisioning/dashboards/lighthouse_yoldark34.json'
RUN wget -qcO - $lighthouse_yoldark34_url | jq '.title = "lighthouse_yoldark34"' | jq '.uid = "t2yHaa3Zz3lou"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$lighthouse_yoldark34_file

#  teku_overview
ARG teku_overview_url='https://grafana.com/api/dashboards/12199/revisions/1/download'
ARG teku_overview_file='/etc/grafana/provisioning/dashboards/teku_overview.json'
RUN wget -qcO - $teku_overview_url | jq '.title = "teku_overview"' >$teku_overview_file

#  nimbus_dashboard
ARG nimbus_dashboard_url='https://raw.githubusercontent.com/status-im/nimbus-eth2/master/grafana/beacon_nodes_Grafana_dashboard.json'
ARG nimbus_dashboard_file='/etc/grafana/provisioning/dashboards/nimbus_dashboard.json'
RUN wget -qcO - $nimbus_dashboard_url | jq '.title = "nimbus_dashboard"' >$nimbus_dashboard_file

# geth_dashboard
ARG geth_dashboard_url='https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/3a400ab90f9402f2233280afd086cb9d6aac2111/dashboard.json'
ARG geth_dashboard_file='/etc/grafana/provisioning/dashboards/geth_dashboard.json'
RUN wget -qcO - $geth_dashboard_url | jq '.title = "geth_dashboard"' | jq 'walk(if . == "${DS_PROMETHEUS}" then "Prometheus" else . end)' >$geth_dashboard_file

# erigon_dashboard
ARG erigon_dashboard_url='https://raw.githubusercontent.com/ledgerwatch/erigon/devel/cmd/prometheus/dashboards/erigon.json'
ARG erigon_dashboard_file='/etc/grafana/provisioning/dashboards/erigon_dashboard.json'
RUN wget -qcO - $erigon_dashboard_url | jq '.title = "erigon_dashboard"' | jq '.uid = "YbLNLr6Mz"' >$erigon_dashboard_file

# node dashboard
ADD node-exporter_dashboard.json /etc/grafana/provisioning/dashboards/

RUN tree /etc/grafana/provisioning/

ENTRYPOINT [ "/run.sh" ]
