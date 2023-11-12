ARG YQ_TAG=4.35.2@sha256:54e3310f27cb1776b2d2a8c66e4644fe5691a066c62583c82e6eadeb531a3c6c
ARG YQ_REPO=mikefarah/yq
FROM $YQ_REPO:$YQ_TAG AS yq

FROM prom/prometheus:latest

COPY --from=yq /usr/bin/yq /usr/local/bin/yq

COPY base-config.yml rootless-base-config.yml custom-prom.yml ./
COPY ./rootless/*.yml ./rootless/
COPY ./docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]