# Build Geth in a stock Go build container
FROM golang:alpine as builder

ARG BUILD_TARGET
ARG USER
ARG UID

RUN apk update && apk add --no-cache make gcc musl-dev linux-headers git ca-certificates

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN go get -d github.com/ethereum/go-ethereum 
RUN cd $GOPATH/src/github.com/ethereum/go-ethereum && git checkout "${BUILD_TARGET}" && GO111MODULE=on go install -ldflags="-linkmode external -extldflags -static" ./cmd/geth
RUN ldd $GOPATH/bin/geth 2>&1 | grep -q "Not a valid dynamic program"
RUN mkdir -p /var/lib/goethereum && chown ${USER}:${USER} /var/lib/goethereum

# Pull all binaries into a second stage deploy scratch container
FROM scratch

ARG USER

# Import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
# Be polite - also make sure this exists and won't be created by an attacker
COPY --from=builder /sbin/nologin /sbin/nologin
# Copy static executable
COPY --from=builder /go/bin/geth /usr/local/bin/
# Copy trusted root CAs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
# Copy data mount point with permissions
COPY --from=builder --chown=${USER} /var/lib/goethereum /var/lib/goethereum

# Use an unprivileged user.
USER ${USER}:${USER}

EXPOSE 8545 30303 30303/udp
ENTRYPOINT ["geth", "--nousb", "--http", "--http.addr", "0.0.0.0", "--http.vhosts", "*", "--http.api", "eth,net", "--ipcdisable", "--datadir", "/var/lib/goethereum"]
CMD ["--goerli"]
