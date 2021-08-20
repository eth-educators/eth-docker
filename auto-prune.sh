#!/bin/bash

if [ $(dpkg-query -W -f='${Status}' bc 2>/dev/null | grep -c "ok installed") = "0" ]; then
  echo "This script requires the bc package, please install it via 'sudo apt install bc'"
  exit 1
fi

cd "$(dirname "$0")";

FREE_DISK=$(df -P /var/lib/docker/volumes | awk '/[0-9]%/{print $(NF-2)}')
TOTAL_DISK=$(df -P /var/lib/docker/volumes | awk '/[0-9]%/{print $(NF-4)}')
PERCENT_FREE=$(echo "percent = ($FREE_DISK / $TOTAL_DISK) * 100; scale = 0; percent / 1" | bc -l)
FREE_DISK_GB=$(echo "$FREE_DISK / 1024 / 1024" | bc)

# If under 100 GiB or 10% free, prune
if [ $FREE_DISK -lt 104857600 -o $PERCENT_FREE -lt 10 ]; then
   if [ ! -f "./ethd" ]; then
      echo "Geth prune should be started, but Geth pruning script not found. Aborting."
      exit 1
   fi
   echo "Starting Geth prune. $FREE_DISK_GB GiB free on disk, which is $PERCENT_FREE percent."
   exec ./ethd prune-geth
fi
