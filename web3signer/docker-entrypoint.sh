#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$(id -u)" = '0' ]; then
  chown -R web3signer /var/lib/web3signer
  exec gosu web3signer docker-entrypoint.sh "$@"
fi

if [ -f /var/lib/web3signer/.migration_fatal_error ]; then
    echo "An error occurred during slashing protection database migration, that makes it unsafe to start Web3signer."
    echo "Until this is manually remedied, Web3signer will refuse to start up."
    echo "Aborting."
    exit 1
fi

/flyway/flyway migrate -url=jdbc:postgresql://postgres/web3signer -user=postgres -password=postgres -locations=filesystem:/opt/web3signer/migrations/postgresql

exec "$@"
