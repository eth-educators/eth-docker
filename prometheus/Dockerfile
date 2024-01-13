ARG YQ_TAG=4
ARG YQ_REPO=mikefarah/yq
FROM $YQ_REPO:$YQ_TAG AS yq

FROM prom/prometheus:latest

COPY --from=yq /usr/bin/yq /usr/local/bin/yq

COPY base-config.yml rootless-base-config.yml /etc/prometheus/
COPY ./rootless/*.yml /etc/prometheus/rootless/
COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]
