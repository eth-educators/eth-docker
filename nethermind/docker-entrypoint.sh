#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
# /nethermind is necessary because keystore and jwtsecret; this can be omitted once merge-ready branch is in
  chown -R nethermind:nethermind /nethermind
  chown -R nethermind:nethermind /var/lib/nethermind
  exec gosu nethermind "$BASH_SOURCE" $@
fi

# Uncomment JSON RPC logging restrictions in the log config XML
#sed -i 's/<!-- \(<logger name=\"JsonRpc\.\*\".*\/>\).*-->/\1/g' /nethermind/NLog.config
# Create JSON RPC logging restrictions in the log config XML
#        <logger name="JsonRpc.*" minlevel="Warn" writeTo="file-async"/>
#        <logger name="JsonRpc.*" minlevel="Warn" writeTo="auto-colored-console-async"/>
#        <logger name="JsonRpc.*" final="true"/>
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Error","-writeTo":"file-async"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Error","-writeTo":"auto-colored-console-async","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-final":"true"}'

exec $@
