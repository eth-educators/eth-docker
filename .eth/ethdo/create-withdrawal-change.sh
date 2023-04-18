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
    __ethdo=~/ethdo/ethdo-arm64
elif [ "${__arch}" = "x86_64" ]; then
    __ethdo=~/ethdo/ethdo
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
    if [[ ! "${__address}" == 0x* || ! "${#__address}" -eq 42 ]]; then
        echo "${__address} is not a valid ETH address. You can try again or hit Ctrl-C to abort."
        continue
    fi
    read -rp "Please verify your desired Ethereum withdrawal address in 0x... format : " __address2
    if [[ "${__address2}" = "${__address}" ]]; then
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
    if [ ! "$(echo "$__mnemonic" | wc -w)" -eq 24 ] && [ ! "$(echo "$__mnemonic" | wc -w)" -eq 12 ]; then
        echo "The mnemonic needs to be 24 or 12 words. You can try again or hit Ctrl-C to abort."
        continue
    else
        break
    fi
done
echo "You may have used a 25th word for the mnemonic. This is not the passphrase for the"
echo "validator signing keys. When in doubt, say no to the next question."
echo
__passphraseCommand=""
read -rp "Did you use a passphrase / 25th word when you created this mnemonic? (no/yes) " __usepassphrase
case "${__usepassphrase}" in
    [Yy]* )
        while true; do
            read -rp "What is your mnemonic passphrase? : " __passphrase
            if [[ -z "${__passphrase}" ]]; then
                echo "The passphrase cannot be empty. You can try again or hit Ctrl-C to abort."
                continue
            fi
            read -rp "Please verify your mnemonic passphrase : " __passphrase2
            if [[ "${__passphrase}" = "${__passphrase2}" ]]; then
                __passphraseCommand="--passphrase=${__passphrase}"
                break
            else
                echo "Passphrase did not match. You can try again or hit Ctrl-C to abort."
            fi
        done;;
    * ) echo "Skipping passphrase entry";;
esac
__advancedCommand=""
read -rp "Did you use a third party such as StakeFish/Staked.us or know that multiple validators share credentials? This is uncommon.  (no/yes) : " __advancedCommand

echo "Creating change-operations.json"
case "${__advancedCommand}" in
    [Yy]* )
        __starting_index=""
        read -rp "Please provide the index position (0 is the most common) : " __starting_index

        # Output is: Private Key: 0x...
        __private_key=$($__ethdo account derive --mnemonic="${__mnemonic}" "${__passphraseCommand}" --show-private-key --path="m/12381/3600/${__starting_index}/0" | awk '{print $NF}')

        $__ethdo validator credentials set --offline --withdrawal-address="${__address}" --private-key="${__private_key}"
        ;;
    * ) $__ethdo validator credentials set --offline --withdrawal-address="${__address}" --mnemonic="${__mnemonic}" "${__passphraseCommand}"
esac

result=$?
if ! [ "$result" -eq 0 ]; then
    echo "Command failed"
    exit "$result"
fi
echo
echo "change-operations.json can be found on your USB drive"
echo
echo "Please shut down this machine and continue online, with the created change-operations.json file"
echo "You can submit it to https://beaconcha.in/tools/broadcast, for example"
