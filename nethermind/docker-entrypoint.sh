#!/bin/bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R nethermind:nethermind /var/lib/nethermind
  exec gosu nethermind "${BASH_SOURCE[0]}" "$@"
fi

# Move legacy xdai dir to gnosis
if [ -d "/var/lib/nethermind/nethermind_db/xdai" ]; then
  mv /var/lib/nethermind/nethermind_db/xdai /var/lib/nethermind/nethermind_db/gnosis
fi

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/nethermind/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/nethermind/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/nethermind/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/nethermind/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/nethermind/ee-secret
fi
if [[ -O "/var/lib/nethermind/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/nethermind/ee-secret/jwtsecret
fi

if [[ "${NETWORK}" =~ ^https?:// ]]; then
  echo "Custom testnet at ${NETWORK}"
  repo=$(awk -F'/tree/' '{print $1}' <<< "${NETWORK}")
  branch=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f1)
  config_dir=$(awk -F'/tree/' '{print $2}' <<< "${NETWORK}" | cut -d'/' -f2-)
  echo "This appears to be the ${repo} repo, branch ${branch} and config directory ${config_dir}."
  if [ ! -d "/var/lib/nethermind/testnet/${config_dir}" ]; then
    # For want of something more amazing, let's just fail if git fails to pull this
    set -e
    mkdir -p /var/lib/nethermind/testnet
    cd /var/lib/nethermind/testnet
    git init --initial-branch="${branch}"
    git remote add origin "${repo}"
    git config core.sparseCheckout true
    echo "${config_dir}" > .git/info/sparse-checkout
    git pull origin "${branch}"
    set +e
  fi
  bootnodes="$(paste -s -d, "/var/lib/nethermind/testnet/${config_dir}/bootnode.txt")"
  __network="--config none.cfg --Init.ChainSpecPath=/var/lib/nethermind/testnet/${config_dir}/chainspec.json --Discovery.Bootnodes=${bootnodes} \
--JsonRpc.EnabledModules=Eth,Subscribe,Trace,TxPool,Web3,Personal,Proof,Net,Parity,Health,Rpc,Debug,Admin --Pruning.Mode=None --Init.IsMining=false"
else
  __network="--config ${NETWORK} --JsonRpc.EnabledModules Web3,Eth,Subscribe,Net,Health,Parity,Proof,Trace,TxPool"
fi

__memtotal=$(awk '/MemTotal/ {printf "%d", int($2/1024/1024)}' /proc/meminfo)
if [ "${ARCHIVE_NODE}" = "true" ]; then
  echo "Nethermind archive node without pruning"
  __prune="--Sync.DownloadBodiesInFastSync=false --Sync.DownloadReceiptsInFastSync=false --Sync.FastSync=false --Sync.SnapSync=false --Sync.FastBlocks=false --Pruning.Mode=None --Sync.PivotNumber=0"
  if [ "${__memtotal}" -gt 62 ]; then
    __memhint="--Init.MemoryHint=4096000000"
  else
    __memhint="--Init.MemoryHint=1024000000"
  fi
else
  __parallel=$(($(nproc)/4))
  if [ "${__parallel}" -lt 2 ]; then
    __parallel=2
  fi
  __prune="--Pruning.FullPruningMaxDegreeOfParallelism=${__parallel}"
  if [ "${AUTOPRUNE_NM}" = true ]; then
    __prune="${__prune} --Pruning.FullPruningTrigger=VolumeFreeSpace --Pruning.FullPruningThresholdMb=375810"
  fi
  if [ "${__memtotal}" -gt 30 ]; then
    __prune="${__prune} --Pruning.FullPruningMemoryBudgetMb=16384"
    __memhint=""
  elif [ "${__memtotal}" -gt 14 ]; then
    __prune="${__prune} --Pruning.FullPruningMemoryBudgetMb=4096"
    __memhint="--Init.MemoryHint=1024000000"
  else
    __memhint="--Init.MemoryHint=1024000000"
  fi
  echo "Using pruning parameters:"
  echo "${__prune}"
fi

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__network} ${__memhint} ${__prune} ${EL_EXTRAS}
