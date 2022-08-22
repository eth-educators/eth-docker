#!/bin/bash
set -Eeuo pipefail

# Copy keys, then restart script without root
if [ "$(id -u)" = '0' ]; then
  cp /validator_keys/keystore-*.json /var/lib/teku/validator-keys/
  chown teku:teku /var/lib/teku/validator-keys/*
  chmod 600 /var/lib/teku/validator-keys/*
  echo "Copied validator key(s) from .eth/validator_keys"
  echo
  if [ -f /validator_keys/slashing_protection.json ]; then
    mkdir /val_keys
    cp /validator_keys/slashing_protection.json /val_keys/
    chown teku:teku /val_keys/*
  fi
  exec gosu teku "$BASH_SOURCE" "$@"
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
  /opt/teku/bin/teku slashing-protection import --data-path=/var/lib/teku --from=${file}
done

if [ ${__non_interactive} = 1 ]; then
  for file in /var/lib/teku/validator-keys/keystore-*.json ; do
    filename=$(basename $file .json)
    echo "$KEYSTORE_PASSWORD" > "/var/lib/teku/validator-passwords/$filename.txt"
  done
  exit 0
fi

# Only reached in interactive mode

# Prompt for password. There's no check that the password is right.

echo "Storing the validator key password(s) in plain text will allow the validator to start automatically without user input."
echo
while true; do
  read -rp "Do you wish to store the validator key password(s) inside this container? (y/n) " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) echo "Not storing plaintext validator key password(s)."; echo; echo "Please adjust teku-base.yml and see instructions in README.md on how to start the client"; exit;;
    * ) echo "Please answer yes or no.";;
  esac
done
echo
while true; do
  read -rp "Do all validator keys have the same password? (y/n) " yn
  case $yn in
    [Yy]* ) justone=1; break;;
    [Nn]* ) justone=0; break;;
    * ) echo "Please answer yes or no.";;
  esac
done
echo
if [ $justone -eq 1 ]; then
  while true; do
    read -srp "Please enter the password for your validator key(s): " password1
    echo
    read -srp "Please re-enter the password: " password2
    echo
    if [ "$password1" == "$password2" ]; then
      break
    else
      echo "The two entered passwords do not match, please try again."
      echo
    fi
  done
  for file in /var/lib/teku/validator-keys/keystore-*.json ; do
    filename=$(basename $file .json)
    echo "$password1" > "/var/lib/teku/validator-passwords/$filename.txt"
  done
else
  for file in /var/lib/teku/validator-keys/keystore-*.json ; do
    filename=$(basename $file .json)
    while true; do
      read -srp "Please enter the password for your validator key stored in $filename: " password1
      echo
      read -srp "Please re-enter the password: " password2
      echo
      if [ "$password1" == "$password2" ]; then
        break
      else
        echo "The two entered passwords do not match, please try again."
        echo
      fi
    done
    echo "$password1" > "/var/lib/teku/validator-passwords/$filename.txt"
  done
fi

chmod 600 /var/lib/teku/validator-passwords/*

echo
echo "Validator key password(s) have been stored."
echo "Please note: This tool currently does not verify that the validator key password(s) are correct. If password(s) don't match, just run this routine again."
echo
