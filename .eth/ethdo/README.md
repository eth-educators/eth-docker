# Changing withdrawal credentials

eth-docker supports using ethdo in an online/offline fashion to prepare withdrawal credential changes files.
This follows the [ethdo instructions](https://github.com/wealdtech/ethdo/blob/master/docs/changingwithdrawalcredentials.md) for this process.

**Do NOT under any circumstances enter your mnemonic into a machine that is online or used for daily tasks**

## Check whether your validator has a withdrawal address set

[Metrika](https://app.metrika.co/ethereum/dashboard/withdrawals-overview) will let you see whether your validator has a withdrawal address set.
If yes, that is where consensus layer rewards will be swept automatically (every 4-5 days at ~500,000 validators total) and where your funds will be sent when exiting.

You can use `./ethd keys list` to get a list of your validator public keys that are currently active on your system.

## Offline preparation

On your machine running eth-docker, run `./ethd keys prepare-address-change`.

Under the hood this will run `ethdo --connection <FIRST_CL_IN_CL_NODE> --allow-insecure-connections validator credentials set --prepare-offline`
which creates an `offline-preparation.json` file in `./.eth/ethdo`.
This file contains a list of all validators currently on the network and is necessary for the offline machine.

This command will also download `ethdo` itself into this directory.

Copy the contents of this directory, including this `README.md`, `ethdo`, `ethdo-arm64`, the `offline-preparation.json`, and the `create-withdrawal-change.sh` script, to a USB stick (we will call it Data USB).

You should also create a new text file on the Data USB that contains the address you want your validator rewards to go to.
This has to be an address you control. Good choices are a hardware wallet where the mnemonic was
**never** online or a contract such as a [multi-signature safe](https://app.safe.global).

**Triple-check the withdrawal address you choose! You can only set this once**

If you do not provide the address through a USB stick you will have to type it manually which is prone to human error.

## Make Linux Live USB

Get the [Ubuntu Desktop](https://ubuntu.com/download/desktop) ISO and burn it to a second USB stick (we will call it Live USB) with [Balena Etcher](https://www.balena.io/etcher) or [Rufus](https://rufus.ie/en/).

Plug in the Live USB to your offline computer and turn it on. You will likely need to override the boot target in the UEFI(BIOS) settings. Methods to do this vary by device: Common key interrupts are F2, F8, F12, DEL and Enter.
While you are updating the boot target, it would be proper to additionally turn off WIFI, Bluetooth and LAN integrated devices.

Upon saving those settings and exiting the UEFI(BIOS) interface, you will be prompted with a list of options.
Choose "Try Ubuntu". Do not install Ubuntu.

After Ubuntu loads, insert the Data USB that holds `ethdo` and the other files from the Offline preparation step.

## Create change credentials file

Verify your internet has been disabled by attempting to visit a website, ping through terminal, or looking in the upper right corner of the desktop.

Open a "Terminal", and cd to the Data USB directory. It will likely be in `/media/ubuntu/USBNAME`. You can use the Files app and right-click the USB, then look at Properties, to see where it is mounted.

Run `bash create-withdrawal-change.sh`.

You will be prompted to specify the withdrawal address you want your funds to be sent to. You should copy that value from the text file.

**Triple-check the withdrawal address you set here! You can only set this once**

You will then be prompted to provide the mnemonic or "seed phrase" of your validator(s). This is needed to sign the change withdrawal request.
To clarify, this is the mnemonic of the validators' "withdrawal key", which, if you used staking-deposit-cli to make the keys,
is also the mnemonic of your validator signing keys. It is not the mnemonic of the depositing address, or the withdrawal address.

A file `change-operations.json` will then be created and saved on the Data USB for use with eth-docker and `ethdo` on your online computer.

Shut down Ubuntu which will make your PC "forget" anything it knew about your mnemonic during this process.

At this point your Live USB will no longer be needed.

## Broadcast changes to the chain

### Using the beacocha.in explorer

Did I mention to **triple-check the withdrawal address you have set? You can only set this once!**

Go to https://beaconcha.in/tools/broadcast and drag-drop the `change-operations.json` file in. It will be broadcast to the chain.

### Using your own eth-docker CL

Insert the Data USB to your online computer where eth-docker is running.

Copy the `change-operations.json` from the Data USB to `./.eth/ethdo` on your eth-docker node.

Run `./ethd keys send-address-change`. You will have one more chance to verify your withdrawal address.

Did I mention to **triple-check the withdrawal address you have set? You can only set this once!**

If a Shanghai/Capella fork has been announced on your chain, the changes will be loaded into the consensus layer client
for broadcast. If Shanghai/Capella is live, they will be broadcasted. Inclusion should take ~3 days after the hardfork date if
everyone piles in at once or should be almost immediate if you have waited.

## Check whether your validator has a withdrawal address set

Obsessively refresh [Metrika](https://app.metrika.co/ethereum/dashboard/withdrawals-overview) to see whether your validator now has a withdrawal address set.
If yes, that is where consensus layer rewards will be swept automatically every 4-5 days at ~500,000 validators total.

You can use `./ethd keys list` to get a list of your validator public keys that are currently active on your system.
