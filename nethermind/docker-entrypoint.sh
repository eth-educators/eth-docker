#!/usr/bin/env bash

if [ "$(id -u)" = '0' ]; then
# /nethermind is necessary because keystore and jwtsecret; this can be omitted once merge-ready branch is in
  chown -R nethermind:nethermind /nethermind
  chown -R nethermind:nethermind /var/lib/nethermind
  exec gosu nethermind "$BASH_SOURCE" $@
fi

# Shut up about RPC calls
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Error","-writeTo":"file-async"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-minlevel":"Error","-writeTo":"auto-colored-console-async","-final":"true"}'
dasel put document -f /nethermind/NLog.config -p xml -d json 'nlog.rules.logger.[]' '{"-name":"JsonRpc.*","-final":"true"}'

exec $@
