#!/bin/bash
host=$(echo $1 | awk -F/ '{print $3}')
protocol=$(echo $1 | awk -F/ '{print $1}')
case "$host" in
  *:*) target="tcp://$host" ;;
  *)
    if [ "$protocol" = https: ]; then
      target="tcp://$host:443"
    elif [ "$protocol" = http: ]; then
      target="tcp://$host:80"
    else
      echo "Unknown protocol, skipping liveness check"
      return 0
    fi
    ;;
esac
shift
dockerize -wait $target "$@"
