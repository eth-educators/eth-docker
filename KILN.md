# Getting up and running on Kintsugi testnet

## Obtain testnet eth
- Create a throwaway ETH address in metamask.
- Fund this address with Kiln ETH using the FaucETH at https://kiln.themerge.dev/. Note the faucet gets hammered by bots, come to [ethstaker Discord](https://discord.io/ethstaker) if you have trouble
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
- Clone this tool and get into the `merge` branch
  - `git clone https://github.com/eth-educators/eth-docker.git merge-test && cd merge-test && git fetch origin merge && git checkout merge`


## Configure the clients you wish to run
- Configure via ethd
  - `./ethd config`
  - `docker-compose build` - this can take a while because it's source builds. You likely have time to walk the dog :)
- Generate the keystore files. This mnemonic should be considered compromised, as it is not generated on an air-gapped
machine.
  - `docker-compose run --rm deposit-cli-new --eth1_withdrawal_address YOURKILNADDRESS`
- Deposit for this key at the [launchpad](https://kiln.launchpad.ethereum.org/).
- Import the keys: `./ethd keyimport`
- Start the stack:
  - `./ethd up`
- Look at logs and see consensus and execution client synchronizing, and the validator client validating:
  - `./ethd logs -f consensus`
  - `./ethd logs -f execution`
  - `./ethd logs -f validator` - for those clients that have a separate validator client, like Lighthouse and Prysm
- Observe your validator at https://beaconchain.kiln.themerge.dev , by entering its public key or the ETH address you funded it from
- If you want to try a different combo, first `./ethd terminate` so the chain data gets deleted, then just `./ethd config`, choose your clients,
  **wait 15 minutes**, `./ethd keyimport` and `./ethd up`. The 15 minute wait is there to avoid slashing.

Note: Not all consensus/execution client combinations have been tested. Please join us on ethstaker Discord to discuss the results of your experimentation!
And above all, have fun!

Your jwt secret is in `./kiln-secrets`
