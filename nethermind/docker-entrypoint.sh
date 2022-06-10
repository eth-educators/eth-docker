#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
# /nethermind is necessary because keystore and jwtsecret; this can be omitted once merge-ready branch is in
  chown -R nethermind:nethermind /nethermind
  chown -R nethermind:nethermind /var/lib/nethermind
  exec gosu nethermind "$BASH_SOURCE" $@
fi

# Create JSON RPC logging restrictions in the log config XML
#        <logger name="JsonRpc.*" minlevel="Warn" writeTo="file-async"/>
#        <logger name="JsonRpc.*" minlevel="Warn" writeTo="auto-colored-console-async"/>
#        <logger name="JsonRpc.*" final="true"/>
# Set the JSON RPC logging level
LOG_LINE=$(awk '/<logger name=\"\*\" minlevel=\"Off\" writeTo=\"seq\" \/>/{print NR}' /nethermind/NLog.config)
sed -e "${LOG_LINE} i \    <logger name=\"JsonRpc\.\*\" final=\"true\"/>\\n" -i /nethermind/NLog.config
sed -e "${LOG_LINE} i \    <logger name=\"JsonRpc\.\*\" minlevel=\"Warn\" writeTo=\"auto-colored-console-async\" final=\"true\"/>" -i /nethermind/NLog.config
sed -e "${LOG_LINE} i \    <logger name=\"JsonRpc\.\*\" minlevel=\"Warn\" writeTo=\"file-async\"\/>" -i /nethermind/NLog.config
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger' '{"-name":"JsonWebAPI.Microsoft.Extensions.Diagnostics.HealthChecks.DefaultHealthCheckService","-maxlevel":"Error","-final":"true"}{"-name":"JsonWebAPI*","-minlevel":"Error","-writeTo":"file-async"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonWebAPI*","-minlevel":"Error","-writeTo":"auto-colored-console-async","-final":"true"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonWebAPI*","-final":"true"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Warn","-writeTo":"file-async"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Warn","-writeTo":"auto-colored-console-async","-final":"true"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-final":"true"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"*","-minlevel":"Off","-writeTo":"seq"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"*","-minlevel":"Info","-writeTo":"file-async"}'
#dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"*","-minlevel":"Info","-writeTo":"auto-colored-console-async"}'

exec $@
