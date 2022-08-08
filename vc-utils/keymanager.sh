#!/usr/bin/env bash

call_api() {
    set +e
    if [ -z "${TLS:+x}" ]; then
        __result=$(curl -m 10 -s -X ${__http_method} -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $__token" \
            --data "${__api_data}" http://${__api_container}:7500/${__api_path})
    else
        __result=$(curl -k -m 10 -s -X ${__http_method} -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $__token" \
            --data "${__api_data}" https://${__api_container}:7500/${__api_path})
    fi
    __return=$?
    if [ $__return -ne 0 ]; then
        echo "Error encountered while trying to call the keymanager API via curl."
        echo "Please make sure ${__api_container} is up and shows the key manager API, port 7500, enabled."
        echo "Error code $__return"
        exit $__return
    fi
    set -e
}

get-token() {
    if [ -z "${PRYSM:+x}" ]; then
        __token=$(cat $__token_file)
    else
        __token=$(sed -n 2p $__token_file)
    fi
}

print-api-token() {
    get-token
    echo $__token
}

validator-list() {
    get-token
    __api_path=eth/v1/keystores
    __api_data=""
    __http_method=GET
    call_api
    if ! echo $__result | grep -q "data"; then
        echo "The key manager API query failed. Output:"
        echo $__result
        exit 1
    fi
    if [ $(echo $__result | jq '.data | length') -eq 0 ]; then
        echo "No keys loaded"
    elif [ -n "${LSBUGGED:+x}" ]; then
        echo "Validator public keys"
        echo $__result | jq -r '.data[].validatingPubkey'
    else
        echo "Validator public keys"
        echo $__result | jq -r '.data[].validating_pubkey'
    fi
}

validator-delete() {
    if [ -z "$__pubkey" ]; then
      echo "Please specify a validator public key to delete"
      exit 1
    fi
    get-token
    __api_path=eth/v1/keystores
    __api_data="{\"pubkeys\":[\"$__pubkey\"]}"
    __http_method=DELETE
    call_api
    if ! echo $__result | grep -q "data"; then
       echo "The key manager API query failed. Output:"
       echo $__result
       exit 1
    fi
    __status=$(echo $__result | jq -r '.data[].status')
    case ${__status,,} in
        error)
            echo "The key was found but an error was encountered trying to delete it:"
            echo $__result | jq -r '.data[].message'
            ;;
        not_active)
            __file=validator_keys/slashing_protection-${__pubkey::10}--${__pubkey:90}.json
            echo "Validator is not actively loaded."
            if [ -n "${NIMBUGGED:+x}" ]; then
                echo $__result | jq '.slashing_protection' > /$__file
            elif [ -n "${LSBUGGED:+x}" ]; then
                echo $__result | jq '.slashingProtection | fromjson' > /$__file
            else
                echo $__result | jq '.slashing_protection | fromjson' > /$__file
            fi
            chown 1000:1000 /$__file
            chmod 644 /$__file
            echo "Slashing protection data written to .eth/$__file"
            ;;
        deleted)
            __file=validator_keys/slashing_protection-${__pubkey::10}--${__pubkey:90}.json
            echo "Validator deleted."
            if [ -n "${NIMBUGGED:+x}" ]; then
                echo $__result | jq '.slashing_protection' > /$__file
            elif [ -n "${LSBUGGED:+x}" ]; then
                echo $__result | jq '.slashingProtection | fromjson' > /$__file
            else
                echo $__result | jq '.slashing_protection | fromjson' > /$__file
            fi
            chown 1000:1000 /$__file
            chmod 644 /$__file
            echo "Slashing protection data written to .eth/$__file"
            ;;
        not_found)
            echo "The key was not found in the keystore, no slashing protection data returned."
            ;;
        * )
            echo "Unexpected status $__status. This may be a bug"
            exit 1
            ;;
    esac
}

validator-import() {
    __num_files=$(ls -a1 /validator_keys/ | grep '^keystore.*json$' | wc -l)
    if [ $__num_files -eq 0 ]; then
        echo "No keystore*.json files found in .eth/validator_keys/"
        echo "Nothing to do"
        exit 0
    fi
    get-token

    __non_interactive=0
    if echo "$@" | grep -q '.*--non-interactive.*' 2>/dev/null ; then
      __non_interactive=1
    fi

    if [ ${__non_interactive} = 1 ]; then
        __password="${KEYSTORE_PASSWORD}"
    else
        echo "WARNING - imported keys are immediately live. If these keys exist elsewhere,"
        echo "you WILL get slashed. If it has been less than 15 minutes since you deleted them elsewhere,"
        echo "you are at risk of getting slashed. Exercise caution"
        echo
        while true; do
            read -rp "I understand these dire warnings and wish to proceed with key import (No/Yes) " yn
            case $yn in
                [Yy]es) break;;
                [Nn]* ) echo "Aborting import"; exit 0;;
                * ) echo "Please answer yes or no.";;
            esac
        done
        if [ $__num_files -gt 1 ]; then
            while true; do
                read -rp "Do all validator keys have the same password? (y/n) " yn
                case $yn in
                    [Yy]* ) __justone=1; break;;
                    [Nn]* ) __justone=0; break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            __justone=1
        fi
        if [ $__justone -eq 1 ]; then
            while true; do
                read -srp "Please enter the password for your validator key(s): " __password
                echo
                read -srp "Please re-enter the password: " __password2
                echo
                if [ "$__password" == "$__password2" ]; then
                    break
                else
                    echo "The two entered passwords do not match, please try again."
                    echo
                fi
            done
            echo
        fi
    fi
    __imported=0
    __skipped=0
    __errored=0
    for __keyfile in /validator_keys/keystore*.json; do
        [ -f "$__keyfile" ] || continue
        __pubkey=0x$(cat $__keyfile | jq -r '.pubkey')
        if [ $__justone -eq 0 ]; then
            while true; do
                read -srp "Please enter the password for your validator key stored in $__keyfile with public key $__pubkey: " __password
                echo
                read -srp "Please re-enter the password: " __password2
                echo
                if [ "$__password" == "$__password2" ]; then
                    break
                else
                    echo "The two entered passwords do not match, please try again."
                    echo
                fi
                echo
            done
        fi
        __do_a_protec=0
        for __protectfile in /validator_keys/slashing_protection*.json; do
            [ -f "$__protectfile" ] || continue
            if cat $__protectfile | grep -q "$__pubkey"; then
                __do_a_protec=1
                echo "Found slashing protection import file $__protectfile for $__pubkey"
                echo "It will be imported"
                break
            fi
        done
        if [ "$__do_a_protec" -eq 0 ]; then
                echo "No slashing protection import file found for $__pubkey"
                echo "Proceeding without slashing protection."
        fi
        __keystore_json=$(cat $__keyfile)
        if [ -n ${__protectfile:+x} ]; then
            __protect_json=$(cat $__protectfile | jq "select(.data[].pubkey==\"$__pubkey\") | tojson")
        else
            __protect_json=""
        fi
        echo $__protect_json > /tmp/protect.json
        jq --arg keystore_value "$__keystore_json" --arg password_value "$__password" --slurpfile protect_value /tmp/protect.json '. | .keystores += [$keystore_value] | .passwords += [$password_value] | . += {slashing_protection: $protect_value[0]}' <<< '{}' >/tmp/apidata.txt
        __api_data=@/tmp/apidata.txt
        __api_path=eth/v1/keystores
        __http_method=POST
        call_api
        if ! echo $__result | grep -q "data"; then
           echo "The key manager API query failed. Output:"
           echo $__result
           exit 1
        fi
        __status=$(echo $__result | jq -r '.data[].status')
        case ${__status,,} in
            error)
                echo "An error was encountered trying to import the key:"
                echo $__result | jq -r '.data[].message'
                echo
                let "__errored+=1"
                ;;
            imported)
                echo "Validator key was successfully imported: $__pubkey"
                echo
                let "__imported+=1"
                ;;
            duplicate)
                echo "Validator key is a duplicate and was skipped: $__pubkey"
                echo
                let "__skipped+=1"
                ;;
            * )
                echo "Unexpected status $__status. This may be a bug"
                exit 1
                ;;
        esac
    done

    echo "Imported $__imported keys"
    echo "Skipped $__skipped keys"
    if [ $__errored -gt 0 ]; then
        echo "$__errored keys caused an error during import"
    fi
    echo
    echo "IMPORTANT: Only import keys in ONE LOCATION."
    echo "Failure to do so will get your validators slashed: Greater 1 ETH penalty and forced exit."
}

usage() {
    echo "Call validator-keys as \"docker-compose run --rm validator-keys ACTION\", where ACTION is one of:"
    echo "  list"
    echo "     Lists all validator public keys currently loaded into your validator client"
    echo "  delete 0xPUBKEY"
    echo "      Deletes the validator with public key 0xPUBKEY from the validator client, and exports its"
    echo "      slashing protection database"
    echo "  import"
    echo "      Import all keystore*.json in .eth/validator_keys while loading slashing protection data"
    echo "      in slashing_protection*.json files that match the public key(s) of the imported validator(s)"
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
    import)
        validator-import
        ;;
    get-api-token)
        print-api-token
        ;;
    *)
        usage
        ;;
esac
