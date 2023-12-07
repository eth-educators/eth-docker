FROM grafana/grafana:latest

USER root
RUN apk --update add wget tree jq sed su-exec

RUN mkdir -p /etc/grafana/provisioning/dashboards/
RUN mkdir -p /etc/grafana/provisioning/datasources/
RUN chown -R grafana:root /etc/grafana/
COPY --chown=grafana:root ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY --chown=grafana:root ./datasource.yml /etc/grafana/provisioning/datasources/
COPY --chown=grafana:root ./default-alerts/*.yml /etc/grafana/provisioning/alerting/
COPY --chown=grafana:root ./provision.sh /usr/local/bin/
# Belt and suspenders
RUN chmod -R 755 /usr/local/bin/*

ENTRYPOINT [ "/run.sh" ]
