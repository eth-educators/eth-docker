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

# Create JSON RPC logging restrictions in the log config XML
#        <logger name="JsonRpc.*" minlevel="Warn" writeTo="file-async" final="true"/>
#        <logger name="JsonRpc.*" minlevel="Warn" writeTo="auto-colored-console-async" final="true"/>
#        <logger name="JsonRpc.*" final="true"/>
# Set the JSON RPC logging level
#LOG_LINE=$(awk '/<logger name=\"\*\" minlevel=\"Off\" writeTo=\"seq\" \/>/{print NR}' /nethermind/NLog.config)
#sed -e "${LOG_LINE} i \    <logger name=\"JsonRpc\.\*\" final=\"true\"/>\\n" -i /nethermind/NLog.config
#sed -e "${LOG_LINE} i \    <logger name=\"JsonRpc\.\*\" minlevel=\"Warn\" writeTo=\"auto-colored-console-async\" final=\"true\"/>" -i /nethermind/NLog.config
#sed -e "${LOG_LINE} i \    <logger name=\"JsonRpc\.\*\" minlevel=\"Warn\" writeTo=\"file-async\" final=\"true\"\/>" -i /nethermind/NLog.config
# dasel 2.x syntax
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger' -v '{"-name":"JsonWebAPI.Microsoft.Extensions.Diagnostics.HealthChecks.DefaultHealthCheckService","-maxlevel":"Error","-final":"true"}{"-name":"JsonWebAPI*","-minlevel":"Error","-writeTo":"file-async","-final":"true"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"JsonWebAPI*","-minlevel":"Error","-writeTo":"auto-colored-console-async","-final":"true"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"JsonWebAPI*","-final":"true"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"JsonRpc.*","-minlevel":"Warn","-writeTo":"file-async","-final":"true"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"JsonRpc.*","-minlevel":"Warn","-writeTo":"auto-colored-console-async","-final":"true"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"JsonRpc.*","-final":"true"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"*","-minlevel":"Off","-writeTo":"seq"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"*","-minlevel":"Info","-writeTo":"file-async"}'
dasel put -f /nethermind/NLog.config -r xml -w xml -t json 'nlog.rules.logger.[]' -v '{"-name":"*","-minlevel":"Info","-writeTo":"auto-colored-console-async"}'

if [ -n "${JWT_SECRET}" ]; then
  echo -n "${JWT_SECRET}" > /var/lib/nethermind/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/nethermind/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/nethermind/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/nethermind/ee-secret" ]]; then
  # In case someone specificies JWT_SECRET but it's not a distributed setup
  chmod 777 /var/lib/nethermind/ee-secret
fi
if [[ -O "/var/lib/nethermind/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/nethermind/ee-secret/jwtsecret
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
  __prune="--Pruning.FullPruningMaxDegreeOfParallelism=${__parallel} --Pruning.Mode=Full"
  if [ "${AUTOPRUNE_NM}" = true ]; then
    __prune="${__prune} --Pruning.FullPruningTrigger=VolumeFreeSpace --Pruning.FullPruningThresholdMb=375810"
  fi
  echo "Using pruning parameters:"
  echo "${__prune}"
  if [ "${__memtotal}" -gt 62 ]; then
    __memhint=""
  else
    __memhint="--Init.MemoryHint=1024000000"
  fi
fi
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__memhint} ${__prune} ${EL_EXTRAS}
