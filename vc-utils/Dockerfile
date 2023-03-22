FROM debian:bullseye-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl jq gosu
COPY --chown=1000:1000 ./keymanager.sh /usr/local/bin/
# Belt and suspenders
RUN chmod -R 755 /usr/local/bin/*
