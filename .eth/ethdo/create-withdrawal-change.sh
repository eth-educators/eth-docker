#!/usr/bin/env bash
cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
set -e
echo "Copying ethdo to home directory, ~/ethdo"
mkdir -p ~/ethdo
cp ethdo ~/ethdo/
cp ethdo-arm64 ~/ethdo/
chmod +x ~/ethdo/*
set +e

__arch=$(uname -m)

if [ "${__arch}" = "aarch64" ]; then
    __ethdo=./ethdo-arm64
elif [ "${__arch}" = "x86_64" ]; then
    __ethdo=./ethdo
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
ping -c 4 1.1.1.1 && { echo; echo "Machine is online, please disconnect from Internet"; exit 1; }
ping -c 4 8.8.8.8 && { echo; echo "Machine is online, please disconnect from Internet"; exit 1; }
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

read -rp "Do you want to break change-operations.json into individual files for use with CLWP? (no/yes) " yn
case $yn in
    [Yy]* ) ;;
    * ) echo "Please shut down this machine and continue online, with the change-operations.json file"; exit 0;;
esac

file_count=0
cat ./change-operations.json | sed "s/},{\"message/}]\n[{\"message/g" | sed -e '$a\' | {
    while read line
    do
        val_index=$(echo $line | grep -Eo '"validator_index"[^,]*' | grep -Eo '[^:]*$' | tr -d '"')
        echo ${line} > "${val_index}".json
        file_count=$((file_count+1))
    done
    echo "$file_count <validator-index>.json files created on USB for use with CLWP"
}
echo "Please shut down this machine and continue online"
