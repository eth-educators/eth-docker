#!/bin/bash
set -Eeuo pipefail

__password=$(echo $RANDOM | md5sum | head -c 32)

echo "$__password" >/tmp/password.txt
echo "Wallet password created"
set +e
__result=$(validator --datadir=/var/lib/prysm wallet create --"${NETWORK}" --wallet-dir=/var/lib/prysm --keymanager-kind=imported --accept-terms-of-use --wallet-password-file=/tmp/password.txt 2>&1)
if echo "$__result" | grep -qi error; then
    echo "An error occurred while attempting to create a Prysm wallet"
    echo "$__result"
    exit 1
else
    echo "$__result"
fi
set -e
echo "Wallet has been created"
echo "$__password" >/var/lib/prysm/password.txt
chmod 600 /var/lib/prysm/password.txt
echo "Wallet password stored"
