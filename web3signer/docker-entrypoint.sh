#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R web3signer /var/lib/web3signer
  exec gosu web3signer docker-entrypoint.sh "$@"
fi

/flyway/flyway migrate -url=jdbc:postgresql://postgres/web3signer -user=postgres -password=postgres -locations=filesystem:/opt/web3signer/migrations/postgresql

exec "$@"
