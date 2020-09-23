from python:buster

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
RUN mkdir -p /var/lib/depcli-data && chown ${USER}:${USER} /var/lib/depcli-data

WORKDIR /var/lib/depcli
USER ${USER}
RUN git clone https://github.com/ethereum/eth2.0-deposit-cli.git
USER root
RUN cd eth2.0-deposit-cli && pip3 install -r requirements.txt && python3 setup.py install

USER ${USER}
WORKDIR /var/lib/depcli/eth2.0-deposit-cli

ENV numvals 1
ENV chain medalla

ENTRYPOINT ./deposit.sh --folder /var/lib/depcli-data --num_validators $numvals --chain $chain 
