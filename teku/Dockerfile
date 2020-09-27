# Build Teku in a stock debian container
FROM openjdk:14-slim-buster as builder

ARG BUILD_TARGET

RUN apt-get update && apt-get install -y ca-certificates git

WORKDIR /usr/src
RUN git clone https://github.com/PegaSysEng/teku.git && cd teku && git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET} && ./gradlew installDist

# Pull all binaries into a second stage deploy debian container
FROM openjdk:14-slim-buster

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

RUN mkdir -p /var/lib/teku/validator-keys && mkdir -p /var/lib/teku/validator-passwords && chown -R ${USER}:${USER} /var/lib/teku

# Copy executable
COPY --from=builder /usr/src/teku/build/install/teku/. /usr/local/teku/
COPY ./copy-teku-validator-keys.sh /usr/local/bin

# Use an unprivileged user.
USER ${USER}:${USER}

#ENTRYPOINT ["beacon_node", "--data-dir=/var/lib/nimbus", "--web3-url=http://geth:8545", "--network=medalla", "--log-file=/var/lib/nimbus/beacon_node.log"]
