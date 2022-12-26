FROM grafana/grafana:latest

USER root
RUN apk --update add wget tree jq sed su-exec

RUN mkdir -p /etc/grafana/provisioning/dashboards/
RUN mkdir -p /etc/grafana/provisioning/datasources/
RUN chown -R grafana:root /etc/grafana/
COPY --chown=grafana:root ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY --chown=grafana:root ./datasource.yml /etc/grafana/provisioning/datasources/
COPY --chown=grafana:root ./provision-dashboards.sh /usr/local/bin/
COPY --chown=grafana:root ./nethermind_dashboard.json /tmp/
# Belt and suspenders
RUN chmod -R 755 /usr/local/bin/*

ENTRYPOINT [ "/run.sh" ]
