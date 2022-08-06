#!/usr/bin/env bash

call_api() {
    set +e
    if [ -z "${TLS:+x}" ]; then
        result=$(curl -m 10 -s -X ${__http_method} -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $__token" \
            --data "${__api_data}" http://${__api_container}:7500/${__api_path})
    else
        result=$(curl -k -m 10 -s -X ${__http_method} -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $__token" \
            --data "${__api_data}" https://${__api_container}:7500/${__api_path})
    fi
    return=$?
    if [ $return -ne 0 ]; then
        echo "Error encountered while trying to call the keymanager API via curl. Error code $return"
        exit $return
    fi
    set -e
}

print-api-token() {
    if [ -z "${PRYSM:+x}" ]; then
        __token=$(cat $__token_file)
    else
        __token=$(sed -n 2p $__token_file)
    fi
    echo $__token
}

validator-list() {
    if [ -z "${PRYSM:+x}" ]; then
        __token=$(cat $__token_file)
    else
        __token=$(sed -n 2p $__token_file)
    fi
    __api_path=eth/v1/keystores
    __api_data=""
    __http_method=GET
    call_api
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
}

validator-delete() {
    if [ -z "$__pubkey" ]; then
      echo "Please specify a validator public key to delete"
      exit 1
    fi
    if [ -z "${PRYSM:+x}" ]; then
        __token=$(cat $__token_file)
    else
        __token=$(sed -n 2p $__token_file)
    fi
    __api_path=eth/v1/keystores
    __api_data="{\"pubkeys\":[\"$__pubkey\"]}"
    __http_method=DELETE
    call_api
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
            file=validator_keys/slashing_protection-${__pubkey::10}--${__pubkey:90}.json
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
            file=validator_keys/slashing_protection-${__pubkey::10}--${__pubkey:90}.json
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
}

usage() {
    echo "Call validator-keys as \"docker-compose run --rm validator-keys ACTION\", where ACTION is one of:"
    echo "  list"
    echo "     Lists all validator public keys currently loaded into your validator client"
    echo "  delete 0xPUBKEY"
    echo "      Deletes the validator with public key 0xPUBKEY from the validator client, and exports its"
    echo "      slashing protection database"
    echo "  get-api-token"
    echo "      Print the token for the keymanager API running on port 7500."
    echo "      This is also the token for the Prysm Web UI"
    echo
}

set -e

__token_file=$1
__api_container=$2

case "$3" in
    list)
        validator-list
        ;;
    delete)
        __pubkey=$4
        validator-delete
        ;;
    get-api-token)
        print-api-token
        ;;
    *)
        usage
        ;;
esac
