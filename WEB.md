# Prsym Web UI

The Prysm Web UI is new and still experimental. It is designed to be accessed locally, not remotely,
which means an [SSH tunnel](https://www.howtogeek.com/168145/how-to-use-ssh-tunneling/) is required to access it.

The `prysm-web.yml` file, specified in the `COMPOSE_FILE` variable inside `.env`, enables both Grafana
and Web UI.

## Prepare the validator client

The Web UI will be used to import keys and create a wallet, but we also need the password for this
wallet while starting the validator. To get around this chicken-and-egg problem, you can either
edit `prysm-base.yml` and choose to provide the password whenever the validator starts, or run
`sudo docker-compose run validator-import` now and choose the wallet password you will use during
the Web UI Wallet Creation.

> This password needs to be at least 8 characters long and contain both a number and a special
> character. The script that stores the password here does not enforce that, but the Web UI does.

Either way, once you are done, run `sudo docker-compose up -d eth2` to start the Prysm beacon
and validator.

## Connect to the Web UI

Assuming you will access the Web UI remotely, from a machine that is not running the node, you'll need
to open an SSH connection and tunnel the ports used by the Web UI.

Example ssh command:
```
ssh -L 7500:<host>:7500 -L 3500:<host>:3500 -L 8080:<host>:8080 -L 8081:<host>:8081 -L 3000:<host>:3000 <user>@<host>
```

where `<host>` is the name or IP address of the node.

Placing this into an alias or shell script can make life easier.

Once the SSH tunnel is open, in a browser, open `http://127.0.0.1:7500`. You'll be prompted for a web password,
which doesn't yet exist, and there is an option to "Create a Wallet".

> Note this is insecure http. Encrypting this connection is supported by Prysm, but not yet incorporated in
> this project. Look into TLS keys if you wish to change the gRPC connections to be encrypted.

# Import keys

Assuming you have some `keystore-m` JSON files from `sudo docker-compose run deposit-cli` or some other way
of creating Launchpad compatible keys, click on "Create a Wallet".

> These files are in `.eth2/validator_keys` if you used the `deposit-cli` workflow. You'll want to
> move them to the machine you are running the browser on.

Choose to create an "Imported Wallet" and enter `/var/lib/prysm` as the wallet directory.

Select the `keystore-m` file(s), Continue, provide the password to the keystore, and Continue.

Set a web password. For security reasons this should be different from the web password. Continue.

Set the wallet password.  If you chose to store the wallet password with the validator in a previous step,
make sure it matches here: This is the step where you actually create the wallet with that password.

Continue and you will find yourself inside the Web UI, which will show you the beacon syncing. Once sync is
complete, you will also see validator information.

# Optional: Verify that wallet password was stored correctly

If you chose to start the validator with a stored wallet password, verify that it was stored
correctly by running these commands, one at a time:

```
sudo docker-compose down && sudo docker-compose up -d eth2
sudo docker-compose logs -f validator
```

You'll need to navigate to the root of the Web UI and log in again after the restart.
