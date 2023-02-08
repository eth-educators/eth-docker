# Changing withdrawal credentials

eth-docker supports using ethdo in an online/offline fashion to prepare withdrawal credential changes files.
This follows the [ethdo instructions](https://github.com/wealdtech/ethdo/blob/master/docs/changingwithdrawalcredentials.md) for this process.

**Do NOT under any circumstances enter your mnemonic into a machine that is online or used for daily tasks**

## Check whether your validator has a withdrawal address set

[Metrika](https://app.metrika.co/ethereum/dashboard/withdrawals-overview) will let you see whether your validator has a withdrawal address set.
If yes, that is where consensus layer rewards will be swept automatically every 4-5 days at ~500,000 validators total.

You can use `./ethd keys list` to get a list of your validator public keys.

## Offline preparation

On your node running under eth-docker, run `./ethd keys prepare-address-change`. This will, under the hood, run
`./ethd cmd run --rm ethdo validator credentials set --prepare-offline --timeout 2m --allow-insecure-connections --connection http://consensus:5052`
which creates an `offline-preparation.json` file in `./.eth/ethdo`, this directory. This file contains all validators
on the network, and is used during the offline step.

This command will also download `ethdo` itself into this directory. Copy the contents of this directory, including this `README.md`, `ethdo`, the
`offline-preparation.json`, and the `create-withdrawal-change.sh` script, to a USB stick.

## Make Linux Live USB

Get the [Ubuntu Desktop](https://ubuntu.com/download/desktop) ISO and burn it to a second USB stick with [Balena Etcher](https://www.balena.io/etcher)
or [Rufus](https://rufus.ie/en/).

Take note of the withdrawal address you intend to use. This has to be an address you control. Good choices are a hardware wallet, where the mnemonic was
**never** online, or a contract such as a [multi-signature safe](https://app.safe.global).

**Triple-check the withdrawal address you choose! You can only set this once**

Boot from this USB stick by overriding the boot target in UEFI settings. Methods to do this vary by device: Common key interrupts are F2, F8, F12, DEL and Enter.

When prompted, choose to "Try Ubuntu". Do not install Ubuntu.

Also insert the USB stick that holds `ethdo` and the other files.

## Create change credentials file

Disconnect Ubuntu from Internet, if it is connected. This is in the upper right corner.

Open a "Terminal", and cd to the second USB stick.

Run `./set-withdrawal-address.sh`. This will create a `change-operations.json` file on that USB stick for use with eth-docker and `ethdo`, and
several \<validator-index\>.json files for use with [CLWP](https://clwp.xyz).

**Triple-check the withdrawal address you set here! You can only set this once**

The withdrawal address has to be an address you control. Good choices are a hardware wallet, where the mnemonic was
**never** online, or a contract such as a [multi-signature safe](https://app.safe.global).

Shut down Ubuntu, which will make your PC "forget" anything it knew about your mnemonic during this process.

## Send changes to the chain

Copy the `change-operations.json` from USB to `./eth/ethdo` on your eth-docker node.

Run `./ethd keys send-address-change`. You will have one more chance to verify your withdrawal address.

Did I mention to **triple-check the withdrawal address you have set? You can only set this once!**

If a Shanghai/Capella fork has been announced on your chain, the changes will be loaded into the consensus layer client
for broadcast. If Shanghai/Capella is live, they will be broadcast. Inclusion should take ~3 days after the hardfork date if
everyone piles in at once, or is expected to be immediate if you are sending it later.

## Check whether your validator has a withdrawal address set

Obsessively refresh [Metrika](https://app.metrika.co/ethereum/dashboard/withdrawals-overview) to see whether your validator now has a withdrawal address set.
If yes, that is where consensus layer rewards will be swept automatically every 4-5 days at ~500,000 validators total.

You can use `./ethd keys list` to get a list of your validator public keys.
