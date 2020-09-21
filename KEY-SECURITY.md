Th directory `.eth2/validator_keys` will contain the `deposit_data-TIMESTAMP.json` and `keystore-m_ID.json`
files created by eth2.0-deposit-cli.

Use `deposit_data-TIMESTAMP.json` for your initial deposit. After that, it can be disposed of.

Use `keystore-m_ID.json` files to import your validator secret keys into the validator
instance of the client you are running. These files need to be secured when you are done
with the initial import.

#Key Security

The `keystore-m_ID.json` files have to be stored securely outside of this server. Offline
is best, on media that cannot be remotely compromised. Keep the password(s) for
these files secure as well, for example in a local (not cloud-connected) password vault
on a PC that is not on the network, or at the very least not used for online access. 

These files will be needed in case you need to restore your validator(s).

**Caution**
An attacker with access to these files could slash your validator(s) or threaten
to slash your validator(s).

For more on validator key security, read this article: https://www.attestant.io/posts/protecting-validator-keys/

**Critical**
When you ran eth2.0-deposit-cli, a 24-word mnemonic was created. This mnemonic
will be used for eth2 withdrawals in the future. It must be securely kept offline.

Precise methods are beyond this README, but consider something as simple as
a sheet of paper kept in a fireproof envelope in a safe, or one of the steel
mnemonic safeguards that are available.

Test your mnemonic **before** you deposit, so you know that you will be able
to withdraw funds in future.

An attacker with access to your mnemonic can drain your funds.

For more on withdrawal key security, read this article: https://www.attestant.io/posts/protecting-withdrawal-keys/
