#!/usr/bin/env bash

set -e
if [ -z "$3" ]; then
  echo "Please specify a validator public key to delete"
  exit 1
fi
if [ -z "${PRYSM:+x}" ]; then
    token=$(cat $1)
else
    token=$(sed -n 2p $1)
fi
set +e
if [ -z "${TLS:+x}" ]; then
    result=$(curl -m 10 -s -X DELETE -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $token" \
 --data "{\"pubkeys\":[\"$3\"]}" http://$2:7500/eth/v1/keystores)
else
    result=$(curl -k -m 10 -s -X DELETE -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $token" \
 --data "{\"pubkeys\":[\"$3\"]}" https://$2:7500/eth/v1/keystores)
fi
return=$?
if [ $return -ne 0 ]; then
    echo "Error encountered while trying to call the keymanager API via curl. Error code $return"
    exit $return
fi
set -e
if ! echo $result | grep -q "data"; then
   echo "The key manager API query failed. Output:"
   echo $result
   exit 1
fi
status=$(echo $result | jq -r '.data[].status')
case ${status,,} in
    error)
        echo "Query resulted in an error:"
        echo $result | jq -r '.data[].message'
        ;;
    not_active)
        file=validator_keys/slashing_protection-${3::10}--${3:90}.json
        echo "Validator is not actively loaded."
        if [ -n "${NIMBUGGED:+x}" ]; then
            echo $result | jq '.slashing_protection' > /$file
        elif [ -n "${LSBUGGED:+x}" ]; then
            echo $result | jq '.slashingProtection | fromjson' > /$file
        else
            echo $result | jq '.slashing_protection | fromjson' > /$file
        fi
        chown 1000:1000 /$file
        chmod 644 /$file
        echo "Slashing protection data written to .eth/$file"
        ;;
    deleted)
        file=validator_keys/slashing_protection-${3::10}--${3:90}.json
        echo "Validator deleted."
        if [ -n "${NIMBUGGED:+x}" ]; then
            echo $result | jq '.slashing_protection' > /$file
        elif [ -n "${LSBUGGED:+x}" ]; then
            echo $result | jq '.slashingProtection | fromjson' > /$file
        else
            echo $result | jq '.slashing_protection | fromjson' > /$file
        fi
        chown 1000:1000 /$file
        chmod 644 /$file
        echo "Slashing protection data written to .eth/$file"
        ;;
    not_found)
        echo "The key was not found in the keystore, no slashing protection data returned."
        ;;
    error)
        echo "The key was found but an error was encountered trying to delete it."
        ;;
    * )
        echo "Unexpected status $status. This may be a bug"
        exit 1
        ;;
esac
