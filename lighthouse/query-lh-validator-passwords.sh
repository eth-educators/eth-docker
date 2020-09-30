#!/bin/bash
# Ask whether all the validator passwords are the same, then call the parameters that had been passed in

while true; do
  read -p "Do all validator keys have the same password? (y/n) " yn
  case $yn in
    [Yy]* ) justone=1; break;;
    [Nn]* ) justone=0; break;;
    * ) echo "Please answer yes or no.";;
  esac
done

if [ $justone -eq 1 ]; then
  $@ --reuse-password
else
  $@
fi
