#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  mkdir /val_keys
  cp /validator_keys/*.json /val_keys/
  chown prysmvalidator:prysmvalidator /val_keys/*
  exec gosu prysmvalidator "$BASH_SOURCE" "$@"
fi

__non_interactive=0
if echo "$@" | grep -q '.*--non-interactive.*' 2>/dev/null ; then
  __non_interactive=1
fi
for arg do
  shift
  [ "$arg" = "--non-interactive" ] && continue
  set -- "$@" "$arg"
done

shopt -s nullglob
for file in /val_keys/slashing_protection*.json; do
  echo "Found slashing protection file ${file}, it will be imported."
  validator slashing-protection-history import --datadir /var/lib/prysm --slashing-protection-json-file ${file} --accept-terms-of-use --${NETWORK}
done

if [ ${__non_interactive} = 1 ]; then
  echo "${WALLET_PASSWORD}" > /var/lib/prysm/password.txt
  chmod 600 /var/lib/prysm/password.txt
  echo "${KEYSTORE_PASSWORD}" > /tmp/keystorepassword.txt
  chmod 600 /tmp/keystorepassword.txt
  exec "$@" --accept-terms-of-use --wallet-password-file /var/lib/prysm/password.txt --account-password-file /tmp/keystorepassword.txt
fi

# Only reached in interactive mode

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
