#!/usr/bin/env bash
cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
__arch=$(uname -m)

if [ "${__arch}" = "aarch64" ]; then
    __ethdo=./ethdo-arm64
    __jq=""
elif [ "${__arch}" = "x86_64" ]; then
    __ethdo=./ethdo
    __jq=./jq
else
    echo "Architecture ${__arch} not recognized - unsure which ethdo to use. Aborting."
    exit 1
fi
if [ ! -f "${__ethdo}" ]; then
    echo "Unable to find ethdo executable at \"${BASH_SOURCE[0]}/${__ethdo}\". Aborting."
    exit 1
fi
echo "Checking whether Bluetooth is enabled"
systemctl status bluetooth >/dev/null
result=$?
if [ "${result}" -eq 0 ]; then
    echo "Bluetooth found, disabling"
    sudo systemctl stop bluetooth
fi
echo "Checking whether machine is online"
echo
ping -c 4 1.1.1.1 && echo; echo "Machine is online, please disconnect from Internet"; exit 1
ping -c 4 8.8.8.8 && echo; echo "Machine is online, please disconnect from Internet"; exit 1
echo "Safely offline. Running ethdo to prep withdrawal address change."
echo
while true; do
    read -rp "What is your desired Ethereum withdrawal address in 0x... format? : " __address
    if [[ ! ${__address} == 0x* || ! ${#__address} -eq 42 ]]; then
        echo "${__address} is not a valid ETH address. You can try again or hit Ctrl-C to abort."
        continue
    fi
    read -rp "Please verify your desired Ethereum withdrawal address in 0x... format : " __address2
    if [[ ${__address2} = ${__address} ]]; then
        echo "Your new withdrawal address is: ${__address}"
        break
    else
        echo "Addresses did not match. You can try again or hit Ctrl-C to abort."
    fi
done
echo "MAKE SURE YOU CONTROL THE WITHDRAWAL ADDRESS"
echo "This can only be changed once."
while true; do
    read -rp "What is your validator mnemonic? : " __mnemonic
    if ! [ "$(echo $__mnemonic | wc -w)" -eq 24 ]; then
        echo "The mnemonic needs to be 24 words. You can try again or hit Ctrl-C to abort."
        continue
    fi
    read -rp "Please verify your validator mnemonic : " __mnemonic2
    if [[ ${__mnemonic} = ${__mnemonic2} ]]; then
        break
    else
        echo "Mnemonic did not match. You can try again or hit Ctrl-C to abort."
    fi
done
echo "Creating change-operations.json"
$__ethdo validator credentials set --offline --withdrawal-address="${__address}" --mnemonic="${__mnemonic}"
result=$?
if ! [ "$result" -eq 0 ]; then
    echo "Command failed"
    exit "$result"
fi
echo "change-operations.json can be found on your USB drive"
# No jq for ARM64
if [ "${__arch}" = "aarch64" ]; then
    exit 0
fi
read -rp "Do you want to break change-operations.json into individual files for use with CLWP? (no/yes) " yn
case $yn in
    [Yy]* ) ;;
    * ) echo "Please shut down this machine and continue online, with the change-operations.json file"; exit 0;;
esac
if [ ! -f "${__jq}" ]; then
    echo "Unable to find jq executable at \"${BASH_SOURCE[0]}/${__jq}\". Aborting."
    exit 1
fi
for ((i=0; i<"$(${__jq} -ec '.|length' ./change-operations.json)";i++)); do
    __validator_index=$(${__jq} -ec ".[$i].message.validator_index|tonumber" ./change-operations.json)
    echo "$(${__jq} -ec [".[$i]"] ./change-operations.json)" > "${__validator_index}".json
done
echo "$i <validator-index>.json files created on USB for use with CLWP"
echo "Please shut down this machine and continue online"
