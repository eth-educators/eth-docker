#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/* /val_keys/
  chown prysmvalidator:prysmvalidator /val_keys/*
  exec gosu prysmvalidator "$BASH_SOURCE" "$@"
fi


while true; do
  read -rp "Will you import keys via the Web UI? (y/n) " yn
  case $yn in
  [Yy]*)
    import=0
    echo "Skipping import. If you choose to store the wallet password, use the one you created during Web UI wallet creation"
    break
    ;;
  [Nn]*)
    import=1
    echo "Continuing to key import"
    break
    ;;
  *) echo "Please answer yes or no." ;;
  esac
done

echo

if [ $import -ne 0 ]; then
  echo
  "$@"
  echo
fi

echo Storing the wallet password in plain text will allow the validator to start automatically without user input.
echo
while true; do
  read -rp "Do you wish to store the wallet password inside this container? (y/n) " yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*)
    echo "Not storing plaintext wallet password."
    echo
    echo "Please adjust prysm-base.yml and see instructions in README.md on how to start the client"
    exit
    ;;
  *) echo "Please answer yes or no." ;;
  esac
done
echo
while true; do
  if [ $import -ne 0 ]; then
    prompt="Please enter your wallet password - note this is *not* the validator keystore password: "
  else
    prompt="Please choose a wallet password, which you will then also provide during Web UI Wallet Creation: "
  fi
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

