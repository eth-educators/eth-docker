#!/bin/bash
__percent_threshold=10
__kbyte_threshold=104857600

if [ "$(dpkg-query -W -f='${Status}' bc 2>/dev/null | grep -c "ok installed")" = "0" ]; then
  echo "This script requires the bc package, please install it via 'sudo apt install bc'"
  exit 1
fi

cd "$(dirname "$0")" || exit 1


__docker_dir=$(docker system info --format '{{.DockerRootDir}}')
__dryrun=0
__threshold_override=0
for (( i=1; i<=$#; i++ )); do
  var="${!i}"
  if [ "$var" = "--dry-run" ]; then
    __dryrun=1
  fi
  if [ "$var" = "--threshold" ]; then
    j=$((i+1))
    __kbyte_threshold=${!j}
    __threshold_override=1
    re='^[0-9]+$'
    if [ -z "$__kbyte_threshold" ] || [[ ! "$__kbyte_threshold" =~ $re ]]; then
      echo "--threshold requires a size in kbytes"
      exit 1
    fi
  fi
  if [ "$var" = "--help" ]; then
    echo "Check available space on $__docker_dir and output to stdout when it is under 100 GiB or 10%"
    echo "Meant to be run from crontab with a MAILTO, as a simple alerting mechanism."
    echo "For Geth 1.10.x or Nethermind, this can also kick off an automatic prune."
    echo
    echo "--dry-run"
    echo "  Run and alert on diskspace, but do not start a prune"
    echo "--threshold <kbytes>"
    echo "  Disk free threshold in kbytes at which to alert"
    exit 0
  fi
done

FREE_DISK=$(df -P "$__docker_dir" | awk '/[0-9]%/{print $(NF-2)}')
TOTAL_DISK=$(df -P "$__docker_dir" | awk '/[0-9]%/{print $(NF-4)}')
PERCENT_FREE=$(echo "percent = ($FREE_DISK / $TOTAL_DISK) * 100; scale = 0; percent / 1" | bc -l)
FREE_DISK_GB=$(echo "$FREE_DISK / 1024 / 1024" | bc)

# Try and detect the EL
el=nada
var="COMPOSE_FILE"
value=$(sed -n -e "s/^${var}=\(.*\)/\1/p" ".env" || true)
if [[ "${value}" =~ "geth.yml" ]]; then
  __el=geth
  if [ "$__threshold_override" -eq 0 ]; then
    __kbyte_threshold=104857600
  fi
elif [[ "${value}" =~ "nethermind.yml" ]]; then
  __el=nethermind
  if [ "$__threshold_override" -eq 0 ]; then
    __kbyte_threshold=262144000
  fi
fi

# If under kbyte threshold or 10% free, alert
if [ "$FREE_DISK" -lt "${__kbyte_threshold}" ] || [ "$PERCENT_FREE" -lt "${__percent_threshold}" ]; then
  if [ "$__dryrun" -eq 0 ]; then
    if  [ "$__el" = "geth" ] || [ "$__el" = "nethermind" ]; then
      if [ ! -f "./ethd" ]; then
        echo "$__el prune should be started, but $__el pruning script not found. Aborting."
        exit 1
      fi
      echo "Starting $__el prune. $FREE_DISK_GB GiB free on disk, which is $PERCENT_FREE percent."
      exec ./ethd prune-$__el --non-interactive
    fi
  fi
# The previous options will have exited the script before here
  echo "Disk space low, prune or resync may be required. $FREE_DISK_GB GiB free on disk, which is $PERCENT_FREE percent."
fi
