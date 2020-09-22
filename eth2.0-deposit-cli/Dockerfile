from python:buster

RUN mkdir -p /var/lib/depcli

WORKDIR /root
RUN git clone https://github.com/ethereum/eth2.0-deposit-cli.git && cd eth2.0-deposit-cli && pip3 install -r requirements.txt && python3 setup.py install

ENV numvals 1
ENV chain medalla

WORKDIR /root/eth2.0-deposit-cli
ENTRYPOINT ./deposit.sh --folder /var/lib/depcli --num_validators $numvals --chain $chain 
