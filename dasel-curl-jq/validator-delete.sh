#!/usr/bin/env bash

set -e
if [ -z "$3" ]; then
  echo "Please specify a validator public key to delete"
  exit 1
fi
token=$(cat $1)
result=$(curl -s -X DELETE -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $token" \
 --data "{\"pubkeys\":[\"$3\"]}" http://$2:7500/eth/v1/keystores)
if ! echo $result | grep -q "data"; then
   echo "The key manager API query failed. Output:"
   echo $result
   exit 1
fi
status=$(echo $result | jq -r '.data[].status')
case $status in
    error )
        echo "Query resulted in an error:"
        echo $result | jq -r '.data[].message'
        ;;
    not_active )

        file=validator_keys/slashing_protection-${3::10}.json
        echo "Validator is not actively loaded."
        echo "Slashing protection data written to .eth/$file"
        echo $result | jq -r '.slashing_protection' > /$file
        chown 1000:1000 /$file
        chmod 644 /$file
        ;;
    deleted )
        file=validator_keys/slashing_protection-${3::10}.json
        echo "Validator deleted."
        echo "Slashing protection data written to .eth/$file"
        echo $result | jq -r '.slashing_protection' > /$file
        chown 1000:1000 /$file
        chmod 644 /$file
esac
