#!/bin/bash
set -Eeuo pipefail

while true; do
  prompt="Please choose a wallet password: "
  read -srp "${prompt}" password1
  echo
  read -srp "Please re-enter the wallet password: " password2
  if [ "$password1" == "$password2" ]; then
    break
  else
    echo "The two entered passwords do not match, please try again."
    echo
  fi
done

echo
echo "$password1" >/var/lib/prysm/password.txt
chmod 600 /var/lib/prysm/password.txt
echo "Wallet password has been stored."
validator --datadir /var/lib/prysm wallet create --wallet-dir /var/lib/prysm --keymanager-kind direct --accept-terms-of-use --wallet-password-file /var/lib/prysm/password.txt
echo "Wallet has been created."
