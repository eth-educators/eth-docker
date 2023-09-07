from python:3.10-alpine as builder
#from python:3.11-alpine as builder

ARG BUILD_TARGET
ARG SRC_REPO

RUN mkdir -p /src

RUN apk add --update bash git

WORKDIR /src
RUN bash -c "git clone ${SRC_REPO} staking-deposit-cli && cd staking-deposit-cli && git config advice.detachedHead false && git fetch --all --tags \
  && if [[ ${BUILD_TARGET} =~ pr-.+ ]]; then git fetch origin pull/$(echo ${BUILD_TARGET} | cut -d '-' -f 2)/head:deposit-pr; git checkout deposit-pr; else git checkout ${BUILD_TARGET}; fi"

FROM python:3.10-alpine
#FROM python:3.11-alpine

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
