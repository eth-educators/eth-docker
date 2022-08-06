FROM ghcr.io/tomwright/dasel:latest as dasel

FROM livepeerci/curl-jq

COPY --from=dasel /usr/local/bin/dasel /usr/local/bin/
COPY ./validator-delete.sh /usr/local/bin/
