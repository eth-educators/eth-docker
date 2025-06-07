FROM debian:bookworm-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl jq gosu
# A user had root:984 and 755 permissions on /tmp. Root cause unknown; work around it
RUN chmod 1777 /tmp
COPY --chown=1000:1000 ./keymanager.sh /usr/local/bin/
# Belt and suspenders
RUN chmod -R 755 /usr/local/bin/*
