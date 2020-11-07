FROM grafana/grafana

USER root
RUN apk add wget
RUN apk add tree

RUN mkdir -p /etc/grafana/provisioning/dashboards/
RUN mkdir -p /etc/grafana/provisioning/datasources/
COPY ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY ./datasource.yml /etc/grafana/provisioning/datasources/

#  metanull-dashboard
RUN wget -qcO - https://raw.githubusercontent.com/metanull-operator/eth2-grafana/master/eth2-grafana-dashboard-single-source.json >/etc/grafana/provisioning/dashboards/eth2-grafana-dashboard-single-source.json

# prysm-grafana-dashboard
RUN wget -qcO - https://raw.githubusercontent.com/GuillaumeMiralles/prysm-grafana-dashboard/master/less_10_validators.json >/etc/grafana/provisioning/dashboards/less_10_validators.json

RUN tree /etc/grafana/provisioning/

ENTRYPOINT [ "/run.sh" ]
