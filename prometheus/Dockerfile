ARG YQ_TAG=4
ARG YQ_REPO=mikefarah/yq
FROM $YQ_REPO:$YQ_TAG AS yq

FROM prom/prometheus:latest

ARG USER=nobody

COPY --from=yq /usr/bin/yq /usr/local/bin/yq

COPY base-config.yml rootless-base-config.yml /etc/prometheus/
COPY ./rootless/*.yml /etc/prometheus/rootless/
COPY ./docker-entrypoint.sh /usr/local/bin/

# Belt and suspenders
USER root
RUN chmod -R 755 /usr/local/bin/*
RUN find /etc/prometheus -type d -exec chmod 755 {} \;
RUN find /etc/prometheus -type f -exec chmod 664 {} \;
RUN chown -R ${USER}:${USER} /etc/prometheus
USER ${USER}

ENTRYPOINT [ "docker-entrypoint.sh" ]
