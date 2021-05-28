from python:buster as builder

ARG BUILD_TARGET

RUN mkdir -p /src

WORKDIR /src
RUN bash -c "git clone https://github.com/ethereum/eth2.0-deposit-cli.git && cd eth2.0-deposit-cli && git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET}"

FROM python:3.7-alpine

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

COPY --from=builder /src/eth2.0-deposit-cli/requirements.txt /src/eth2.0-deposit-cli/setup.py ./
COPY --from=builder /src/eth2.0-deposit-cli/eth2deposit ./eth2deposit

RUN apk add --update gcc libc-dev linux-headers bash su-exec

RUN pip3 install -r requirements.txt

RUN python3 setup.py install

RUN chown -R ${USER}:${USER} /app

COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh","python3","./eth2deposit/deposit.py" ]
