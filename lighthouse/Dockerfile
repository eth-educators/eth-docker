# Build Lighthouse in a stock Rust build container
FROM rust:latest as builder

ARG BUILD_TARGET

RUN apt-get update && apt-get install -y git gcc g++ make cmake pkg-config libssl-dev

WORKDIR /usr/src
RUN git clone https://github.com/sigp/lighthouse.git && cd lighthouse && git checkout "${BUILD_TARGET}" && make

# Pull all binaries into a second stage deploy alpine container
FROM debian:latest

ARG USER
ARG UID

RUN apt-get update && apt-get install -y ca-certificates

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Create data mount point with permissions
RUN mkdir -p /var/lib/lighthouse && chown ${USER}:${USER} /var/lib/lighthouse
# Copy executable
COPY --from=builder /usr/local/cargo/bin/lighthouse /usr/local/bin/
# Use an unprivileged user.
USER ${USER}:${USER}

#EXPOSE 5052 9000 9000/udp
ENTRYPOINT ["lighthouse", "bn", "--datadir", "/var/lib/lighthouse/", "--http", "--http-address", "0.0.0.0"]
CMD ["--testnet", "medalla", "--eth1-endpoint", "http://geth:8545"]
