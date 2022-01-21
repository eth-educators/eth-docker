#!/bin/bash

echo "USE AT YOUR OWN RISK"
echo "This tool will generate a mnemonic and deposit for one (1) validator at index zero (0)"
echo "on Kintsugi testnet."
echo "You will need a throwaway ETH account, both address and secret key"
echo "This account has to be considered compromised once used here"
echo "Use the faucet at https://kintsugi.themerge.dev/ three times to fund the account with 32.13 Kintsugi ETH"
echo "DO NOT USE A LIVE ACCOUNT"

read -p "Are you sure you're using a throwaway account and want to make this deposit? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

source kintsugi.env

echo "In the next step, do NOT enter a mnemonic used to secure existing funds"
if [[ -z "${VALIDATORS_MNEMONIC}" ]]; then
  read -p "Enter the validator mnemonic or <enter> to generate it: " -r
  echo
  if [[ -z "${REPLY}" ]]; then
    VALIDATORS_MNEMONIC=`eth2-val-tools mnemonic | tee /tmp/secrets/validator_seed.txt`
    echo "Mnemonic has been written to kintsugi-secrets/validator_seed.txt"
  else 
    VALIDATORS_MNEMONIC="${REPLY}"
  fi
fi

if [[ -z "${WITHDRAWALS_MNEMONIC}" ]]; then
  WITHDRAWALS_MNEMONIC="${VALIDATORS_MNEMONIC}"
fi

echo "Once more, ONLY use a throwaway account here. When in doubt hit Ctrl-C to exit"
if [[ -z "${ETH1_FROM_ADDR}" ]]; then
  read -p "Enter the eth1 address to deposit from: " -r
  echo
  ETH1_FROM_ADDR="${REPLY}"
fi

echo "CAUTION - once you enter the private key here, this account has to be considered compromised"
if [[ -z "${ETH1_FROM_PRIV}" ]]; then
  read -p "Enter the private key for your eth1 address: " -r
  echo
  ETH1_FROM_PRIV=${REPLY}
fi

echo "using:"
echo "ETH1_FROM_ADDR: $ETH1_FROM_ADDR"
echo "ETH1_FROM_PRIV: $ETH1_FROM_PRIV"
echo "VALIDATORS_MNEMONIC: $VALIDATORS_MNEMONIC"
echo "WITHDRAWALS_MNEMONIC: $WITHDRAWALS_MNEMONIC"

eth2-val-tools deposit-data \
  --source-min=0 \
  --source-max=1 \
  --amount=$DEPOSIT_AMOUNT \
  --fork-version=$FORK_VERSION \
  --withdrawals-mnemonic="$WITHDRAWALS_MNEMONIC" \
  --validators-mnemonic="$VALIDATORS_MNEMONIC" > $DEPOSIT_DATAS_FILE_LOCATION


# Iterate through lines, each is a json of the deposit data and some metadata
while read x; do
   account_name="$(echo "$x" | jq '.account')"
   pubkey="$(echo "$x" | jq '.pubkey')"
   echo "Sending deposit for validator $account_name $pubkey"
   ethereal beacon deposit \
      --log=/tmp/ethereal.log \
      --allow-unknown-contract=$FORCE_DEPOSIT \
      --address="$DEPOSIT_CONTRACT_ADDRESS" \
      --connection=$ETH1_RPC \
      --data="$x" \
      --value="$DEPOSIT_ACTUAL_VALUE" \
      --from="$ETH1_FROM_ADDR" \
      --privatekey="$ETH1_FROM_PRIV"
   if [ $? -eq 0 ]; then
      echo "Sent deposit for validator $account_name $pubkey"
   else
      echo "Failed to send deposit for validator $account_name $pubkey"
   fi
   sleep 3
done < "$DEPOSIT_DATAS_FILE_LOCATION"

# Output the keys so the clients can import them

eth2-val-tools keystores \
      --insecure \
      --prysm-pass="prysm" \
      --out-loc="/tmp/secrets/keys" \
      --source-max=1 \
      --source-min=0 \
      --source-mnemonic="${VALIDATORS_MNEMONIC}"

echo "prysm" > /tmp/secrets/keys/secrets/prysm-password.txt
echo "Keystores are in kintsugi-secrets/keys"

# eth-docker stuff - fill in MNEMONIC and REWARDS_TO
# Assumes /tmp/.env has been mapped in, and doesn't do error checking

sed "s~^\(REWARDS_TO\s*=\s*\).*$~\1${ETH1_FROM_ADDR}~" /tmp/.env >/tmp/tmpfile
cp /tmp/tmpfile /tmp/.env
#sed "s~^\(VALIDATORS_MNEMONIC\s*=\s*\).*$~\1${VALIDATORS_MNEMONIC}~" /tmp/.env >/tmp/tmpfile
#cp /tmp/tmpfile /tmp/.env

echo "Config file .env has been updated with REWARDS_TO address"
