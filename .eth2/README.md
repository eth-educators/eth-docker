The directory `validator_keys` will contain the `deposit_data-TIMESTAMP.json` and `keystore-m_ID.json`
files created by eth2.0-deposit-cli.

Use `deposit_data-TIMESTAMP.json` for your initial deposit. After that, it can be disposed of.

Use `keystore-m_ID.json` files to import your validator secret keys into the validator
instance of the client you are running. These files need to be secured when you are done
with the initial import.
