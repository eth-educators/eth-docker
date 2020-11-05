# Build Prysm in a stock Go build container
FROM golang:buster as builder

ARG BUILD_TARGET

RUN apt-get update && apt-get install -y cmake libtinfo5 libgmp-dev npm && npm install -g @bazel/bazelisk && bazel version

WORKDIR /go/src
RUN bash -c "git clone https://github.com/prysmaticlabs/prysm.git && cd prysm && git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET} && bazel build --config=release //beacon-chain:beacon-chain && bazel build --config=release //validator:validator && bazel build --config=release //slasher:slasher"

# Pull all binaries into a second stage deploy debian container
FROM debian:buster-slim

ARG USER
ARG UID

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  wget \
  w3m \
  xdg-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Grab dockerize so validator can wait for beacon
#ENV DOCKERIZE_VERSION v0.6.1
#RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
#    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
#    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Copy executable
COPY --from=builder /go/src/prysm/bazel-bin/beacon-chain/linux_amd64_stripped/beacon-chain /usr/local/bin/
COPY --from=builder /go/src/prysm/bazel-bin/validator/linux_amd64_stripped/validator /usr/local/bin/
COPY --from=builder /go/src/prysm/bazel-bin/slasher/linux_amd64_stripped/slasher /usr/local/bin/
COPY ./create-prysm-validator-wallet.sh /usr/local/bin
# Create data mount point with permissions
RUN mkdir -p /var/lib/prysm && chown ${USER}:${USER} /var/lib/prysm && chmod 700 /var/lib/prysm

# Use an unprivileged user.
USER ${USER}:${USER}

#EXPOSE 4000 13000 12000/udp
ENTRYPOINT ["beacon-chain", "--datadir", "/var/lib/prysm", "--http-web3provider", "http://geth:8545", "--rpc-host", "0.0.0.0"]
