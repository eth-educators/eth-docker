# Getting up and running on merge testnets

## Obtain testnet eth
- Create a throwaway ETH address in metamask.
- Fund this address with testnet ETH. Note the faucets get hammered by bots, come to [ethstaker Discord](https://discord.io/ethstaker) if you have trouble
  getting funds.

## Setup Prerequisites
### On Linux
- Install Docker
  - If you already have Docker installed, skip this step
  - Otherwise, run `sudo apt update && sudo apt -y install docker-compose`
  - Make your user part of the docker group: `sudo usermod -aG docker MYUSERNAME` and then `newgrp docker`

### On macOS
- Install Docker Desktop
  - Allocate 8GiB of RAM
- Install pre-requisites via homebrew
  - `brew install coreutils newt`

## Get eth-docker
- Clone this tool and get into the `merge-getready` branch
  - `git clone https://github.com/eth-educators/eth-docker.git merge-ready && cd merge-ready && git fetch origin merge-getready && git checkout merge-getready`
- N.B.: When you log into a fresh Terminal, use `cd ~/merge-ready` to get back into this directory

## Configure the clients you wish to run
- Configure via ethd
  - `./ethd config`
- Build all required images
  - `./ethd cmd build --pull`
- Generate the keystore files. This mnemonic should be considered compromised, as it is not generated on an air-gapped
machine.
  - `docker-compose run --rm deposit-cli-new --eth1_withdrawal_address YOURTESTADDRESS`
- Deposit for this key at the launchpad for your testnet. The `deposit_data` JSON file will be in `.eth/validator_keys`,
 which is "hidden" directory if you use a graphical file explorer.
- Import the keys: `./ethd keyimport`
- Start the stack:
  - `./ethd up`
- Look at logs and see consensus and execution client synchronizing, and the validator client validating:
  - `./ethd logs -f consensus`
  - `./ethd logs -f execution`
  - `./ethd logs -f validator` - for those clients that have a separate validator client, like Lighthouse and Prysm
- Observe your validator at the beaconcha.in site for this testnet, by entering its public key or the ETH address you funded it from
- If you want to try a different combo, first `./ethd terminate` so the chain data gets deleted, then just `./ethd config`, choose your clients,
  **wait 15 minutes**, `./ethd keyimport` and `./ethd up`. The 15 minute wait is there to avoid slashing.

## What to do when TTD changes

If the announced TTD of the chain you are running on changes, you have two options.
- Run `./ethd update`, observe whether it brought in a new TTD. If it did, run `./ethd restart`
- Run `nano .env` and manually change the `OVERRIDE_TTD`. Save, then `./ethd restart`

Note: Not all consensus/execution client combinations have been tested. Please join us on ethstaker Discord to discuss the results of your experimentation!
And above all, have fun!

Your jwt secret is in a docker volume by default
