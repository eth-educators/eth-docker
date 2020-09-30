#!/bin/sh

if [ ! $(lighthouse --version | grep v0.3) ]; then
  echo "Lighthouse is not version 0.3, nothing to migrate"
  echo "Version found is " $(lighthouse --version)
  echo
  echo "This script only migrates from v0.2 to v0.3."
  echo "If you need to migrate from v0.2 to v0.4 or"
  echo "later, please do so manually."
  exit 1
fi

