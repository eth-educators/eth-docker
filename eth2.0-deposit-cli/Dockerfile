from python:buster

ARG USER
ARG UID

RUN adduser \
    --disabled-password \
    --gecos "" \
    --shell "/bin/bash" \
    --uid "${UID}" \
    "${USER}" 

RUN mkdir -p /var/lib/depcli && chown ${USER}:${USER} /var/lib/depcli

USER ${USER}:${USER}
RUN cd ~ && git clone https://github.com/ethereum/eth2.0-deposit-cli.git
USER root
RUN cd /home/${USER}/eth2.0-deposit-cli && pip3 install -r requirements.txt && python3 setup.py install

USER ${USER}:${USER}

ENV numvals 1
ENV chain medalla
WORKDIR /home/${USER}/eth2.0-deposit-cli

ENTRYPOINT ./deposit.sh --folder /var/lib/depcli --num_validators $numvals --chain $chain 
