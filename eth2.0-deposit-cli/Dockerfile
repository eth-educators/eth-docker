from python:buster as builder

ARG USER
ARG UID
ARG BUILD_TARGET

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN mkdir -p /var/lib/depcli && chown ${USER}:${USER} /var/lib/depcli

WORKDIR /var/lib/depcli
USER ${USER}
RUN bash -c "git clone https://github.com/ethereum/eth2.0-deposit-cli.git && cd eth2.0-deposit-cli && git config advice.detachedHead false && git fetch --all --tags && git checkout ${BUILD_TARGET}"

FROM python:3.7-alpine

WORKDIR /app

COPY --from=builder /var/lib/depcli/eth2.0-deposit-cli/requirements.txt /var/lib/depcli/eth2.0-deposit-cli/setup.py ./
COPY --from=builder /var/lib/depcli/eth2.0-deposit-cli/eth2deposit ./eth2deposit

RUN apk add --update gcc libc-dev linux-headers

RUN pip3 install -r requirements.txt

RUN python3 setup.py install

USER ${USER}

ENTRYPOINT [ "python3", "./eth2deposit/deposit.py" ]
