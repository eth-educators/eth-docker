FROM mikefarah/yq:4.35.2@sha256:54e3310f27cb1776b2d2a8c66e4644fe5691a066c62583c82e6eadeb531a3c6c AS configbuilder

# Client list to be provided by grafana-rootless.yml compose service
ARG CLIENT=""

COPY --chown=yq:yq ./*-config.yml .
COPY ./rootless/*.yml ./rootless/
COPY ./select-clients.sh .

# Merges base configs with custom config
# The custom config overrides existing settings, and lists are extended
RUN touch custom-config.yml && \
    yq eval-all '. as $item ireduce ({}; . *+ $item)' base-config.yml custom-config.yml \
    > /workdir/merged.yml

RUN ./select-clients.sh && \
    yq eval-all '. as $item ireduce ({}; . *+ $item)' rootless-with-clients.yml custom-config.yml \
    > /workdir/merged-rootless.yml

FROM prom/prometheus:latest AS runtime

COPY --from=configbuilder /workdir/merged.yml /etc/prometheus/prometheus.yml
COPY --from=configbuilder /workdir/merged-rootless.yml /etc/prometheus/rootless.yml
