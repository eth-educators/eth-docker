# Recommendations

Some recommendations on security of the host, general operation,
and key security.

## Operation

**Do not run two validators**<br />
You'd get yourself slashed, and no-one wants that. Protecting you from this
is a work in progress. Choose one client, and one client only, and run that.

**You need an eth1 source**<br />
This project assumes you'll use geth. It doesn't have to be that, it can
be a 3rd party. You need some source for eth1, so that your validator can
successfully propose blocks.

## Host Security

Steal /u/SomerEsat's stuff and put it here :)

## Before depositing

You likely want to wait to deposit your eth until you can see in the logs
that the eth1 node (e.g. geth) is synchronized and the eth2 beacon node
is fully synchronized, which happens after that. This takes hours on
testnet and could take days on mainnet.

If you deposit before your client stack is fully synchronized and running,
you risk getting penalized for being offline. The offline penalty during
the first 5 months of mainnet will be roughly 0.13% of your deposit per
week.

## Wallet and key security

The security of the wallet you create is **critical**. If it is compromised, you will lose
your balance. Please make sure you understand eth2 staking before you use this project.

When you create the wallet and deposit files, write down your mnemonic and
choose a cryptographically strong password for your keystores. Something long
and not used anywhere else, ideally randomized by a generator.

The directory `.eth2/validator_keys` will contain the `deposit_data-TIMESTAMP.json` and `keystore-m_ID.json`
files created by eth2.0-deposit-cli.

Use `deposit_data-TIMESTAMP.json` for your initial deposit. After that, it can be disposed of.

Use `keystore-m_ID.json` files to import your validator secret keys into the validator
instance of the client you are running. These files need to be secured when you are done
with the initial import.

### Validator Key Security

The `keystore-m_ID.json` files have to be stored securely outside of this server. Offline
is best, on media that cannot be remotely compromised. Keep the password(s) for
these files secure as well, for example in a local (not cloud-connected) password vault
on a PC that is not on the network, or at the very least not used for online access.

Once you have the keystore files secure and they've been imported to the validator container
on your server, you should delete them from the `.eth2` directory.

These files will be needed in case you need to restore your validator(s).

**Caution**<br />
An attacker with access to these files could slash your validator(s) or threaten
to slash your validator(s).

For more on validator key security, read this article: https://www.attestant.io/posts/protecting-validator-keys/

### Withdrawal Key Security

**Critical**<br />
When you ran eth2.0-deposit-cli, a 24-word mnemonic was created. This mnemonic
will be used for eth2 withdrawals in the future. It must be securely kept offline.

Precise methods are beyond this README, but consider something as simple as
a sheet of paper kept in a fireproof envelope in a safe, or one of the steel
mnemonic safeguards that are available.

Test your mnemonic **before** you deposit, so you know that you will be able
to withdraw funds in future.

An attacker with access to your mnemonic can drain your funds.

For more on withdrawal key security, read this article: https://www.attestant.io/posts/protecting-withdrawal-keys/
