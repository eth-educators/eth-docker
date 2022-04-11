FROM grafana/grafana:latest

USER root
RUN apk --update add wget tree jq sed

RUN mkdir -p /etc/grafana/provisioning/dashboards/
RUN mkdir -p /etc/grafana/provisioning/datasources/
COPY ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY ./datasource.yml /etc/grafana/provisioning/datasources/
COPY ./provision-dashboards.sh /usr/local/bin/

ENTRYPOINT [ "/run.sh" ]
