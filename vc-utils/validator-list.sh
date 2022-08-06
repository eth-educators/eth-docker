#!/usr/bin/env bash

set -e
if [ -z "${PRYSM:+x}" ]; then
    token=$(cat $1)
else
    token=$(sed -n 2p $1)
fi
set +e
if [ -z "${TLS:+x}" ]; then
    result=$(curl -m 10 -s -H "Accept: application/json" -H "Authorization: Bearer $token" http://$2:7500/eth/v1/keystores)
else
    result=$(curl -k -m 10 -s -H "Accept: application/json" -H "Authorization: Bearer $token" https://$2:7500/eth/v1/keystores)
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
if [ $(echo $result | jq '.data | length') -eq 0 ]; then
    echo "No keys loaded"
elif [ -n "${LSBUGGED:+x}" ]; then
    echo "Validator public keys"
    echo $result | jq -r '.data[].validatingPubkey'
else
    echo "Validator public keys"
    echo $result | jq -r '.data[].validating_pubkey'
fi
