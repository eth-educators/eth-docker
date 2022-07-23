#!/bin/bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R nethermind:nethermind /var/lib/nethermind
  exec gosu nethermind "$BASH_SOURCE" "$@"
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
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger' '{"-name":"JsonWebAPI.Microsoft.Extensions.Diagnostics.HealthChecks.DefaultHealthCheckService","-maxlevel":"Error","-final":"true"}{"-name":"JsonWebAPI*","-minlevel":"Error","-writeTo":"file-async","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonWebAPI*","-minlevel":"Error","-writeTo":"auto-colored-console-async","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonWebAPI*","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Warn","-writeTo":"file-async","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Warn","-writeTo":"auto-colored-console-async","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"*","-minlevel":"Off","-writeTo":"seq"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"*","-minlevel":"Info","-writeTo":"file-async"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"*","-minlevel":"Info","-writeTo":"auto-colored-console-async"}'

if [ -n "${JWT_SECRET}" ]; then
  echo -n ${JWT_SECRET} > /var/lib/nethermind/ee-secret/jwtsecret
  echo "JWT secret was supplied in .env"
fi

if [[ ! -f /var/lib/nethermind/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(echo $RANDOM | md5sum | head -c 32)
  __secret2=$(echo $RANDOM | md5sum | head -c 32)
  echo -n ${__secret1}${__secret2} > /var/lib/nethermind/ee-secret/jwtsecret
fi

# Check whether we should override TTD
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--Merge.TerminalTotalDifficulty ${OVERRIDE_TTD}"
  echo "Overriding TTD to ${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

exec $@ ${__override_ttd}
