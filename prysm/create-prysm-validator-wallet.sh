#!/bin/bash
# This will be passed arguments that start the validator
echo When asked for a wallet directory below, enter /var/lib/prysm
echo
"$@"

if [ $? -ne 0 ]; then
  exit 1;
fi
echo
echo Storing the wallet password in plain text will allow the validator to start automatically without user input.
echo
while true; do
  read -p "Do you wish to store the wallet password inside this container? (y/n) " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) echo "Not storing plaintext wallet password."; echo; echo "Please adjust prysm-base.yml and see instructions in README.md on how to start the client"; exit;;
    * ) echo "Please answer yes or no.";;
  esac
done
echo
while true; do
  read -sp "Please enter the 'New wallet password' you chose above: " password1
  echo
  read -sp "Please re-enter the 'New wallet password': " password2
  if [ $password1 == $password2 ]; then
    break
  else
    echo "The two entered passwords do not match, please try again."
    echo
  fi
done

echo
echo $password1 >/var/lib/prysm/password.txt
echo "Wallet password has been stored."
