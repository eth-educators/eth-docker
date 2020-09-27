# Build Nimbus in a stock debian container
FROM debian:buster-slim as builder

ARG BUILD_TARGET
ARG METRICS

RUN apt-get update && apt-get install -y build-essential git libpcre3-dev ca-certificates

WORKDIR /usr/src
RUN git clone https://github.com/status-im/nim-beacon-chain && cd nim-beacon-chain && git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET} && make ${METRICS} beacon_node

# Pull all binaries into a second stage deploy debian container
FROM debian:buster-slim

ARG USER
ARG UID

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/usr/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN mkdir -p /var/lib/nimbus && chown ${USER}:${USER} /var/lib/nimbus

# Copy executable
COPY --from=builder /usr/src/nim-beacon-chain/build/beacon_node /usr/local/bin/beacon_node

# Use an unprivileged user.
USER ${USER}:${USER}

ENTRYPOINT ["beacon_node", "--data-dir=/var/lib/nimbus", "--web3-url=http://geth:8545", "--network=medalla", "--log-file=/var/lib/nimbus/beacon_node.log"]
