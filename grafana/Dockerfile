FROM grafana/grafana

USER root
RUN apk add wget
RUN apk add tree
RUN apk add jq

RUN mkdir -p /etc/grafana/provisioning/dashboards/
RUN mkdir -p /etc/grafana/provisioning/datasources/
COPY ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY ./datasource.yml /etc/grafana/provisioning/datasources/

#  prysm_metanull
ARG prysm_metanull_url='https://raw.githubusercontent.com/metanull-operator/eth2-grafana/master/eth2-grafana-dashboard-single-source.json'
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

RUN tree /etc/grafana/provisioning/

ENTRYPOINT [ "/run.sh" ]
