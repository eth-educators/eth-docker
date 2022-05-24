from python:bullseye as builder

ARG BUILD_TARGET

RUN mkdir -p /src

WORKDIR /src
RUN bash -c "git clone https://github.com/ethereum/staking-deposit-cli.git && cd staking-deposit-cli && git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET}"

FROM python:3.10-alpine

ARG USER=depcli
ARG UID=1000

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR /app

COPY --from=builder /src/staking-deposit-cli/requirements.txt /src/staking-deposit-cli/setup.py ./
COPY --from=builder /src/staking-deposit-cli/staking_deposit ./staking_deposit

RUN apk add --update gcc libc-dev linux-headers bash su-exec

RUN pip3 install -r requirements.txt

RUN python3 setup.py install

RUN chown -R ${USER}:${USER} /app

COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh","python3","./staking_deposit/deposit.py" ]
