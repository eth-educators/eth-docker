#!/bin/bash
set -Eeuo pipefail

# allow the container to be started with `--user`
# If started as root, chown the `--datadir` and run heimdalld as heimdall
if [ "$(id -u)" = '0' ]; then
   chown -R heimdall:heimdall /var/lib/heimdall
   exec su-exec heimdall "$BASH_SOURCE" $@
fi

set -x

if [ ! -f /var/lib/heimdall/config/config.toml ]; then
  heimdalld init --home /var/lib/heimdall --chain-id ${HEIMDALL_CHAIN_ID}
  wget -q -O - "${HEIMDALL_SNAPSHOT_FILE}" | tar xzvf - -C /var/lib/heimdall/data/
fi
touch /var/lib/heimdall/setupdone
wget -O /var/lib/heimdall/config/genesis.json ${HEIMDALL_GENESIS_URL} -P /var/lib/heimdall/config
SERVER_IP=$(curl -s ifconfig.me)
sed -i "/seeds =/c\seeds = \"${HEIMDALL_SEEDS}\"" /var/lib/heimdall/config/config.toml
sed -i "/external_address = \".*\"/c\external_address = \"tcp:\/\/${SERVER_IP}:26656\"" /var/lib/heimdall/config/config.toml
sed -i '/26657/c\laddr = "tcp://0.0.0.0:26657"' /var/lib/heimdall/config/config.toml
sed -i "/bor_rpc_url/c\bor_rpc_url = \"${HEIMDALL_BOR_RPC_URL}\"" /var/lib/heimdall/config/heimdall-config.toml
sed -i "/eth_rpc_url/c\eth_rpc_url = \"${HEIMDALL_ETH_RPC_URL}\"" /var/lib/heimdall/config/heimdall-config.toml
sed -i '/amqp_url/c\amqp_url = "amqp://guest:guest@rabbitmq:5672"' /var/lib/heimdall/config/heimdall-config.toml
exec $@
