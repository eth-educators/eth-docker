# eth2-docker v0.05
Unofficial and experimental docker build instructions for eth2 clients

**Short-lived spadina branch**
eth2.0-deposit-cli is ready; clients to come

This project builds clients from source. A similar workflow for
binary images is a TODO, as long as it does not duplicate work
by client teams.

Currently included clients:
- Lighthouse, with local geth
- Prysm, with local geth

# USAGE

- Generate deposit files and an eth2 wallet. This can be done within this project, or outside of it
- Choose a client, decide whether to run a local eth1 node or use a 3rd-party one
- Import the validator keystore files generated in the first step
- Run the client
- Wait until the eth1 node and beacon node are fully synchronized
- Finalize the deposit. This is not done within this project

## Before you start

A file 'default.env' is provided and needs to be copied to '.env'.
If this is not done, running docker-compose will fail.

You likely want to set `GRAFFITI` inside the file `.env`, and you might
adjust `NUM_VAL` if you are going to create keys for more than one validator.

On Linux, `docker-compose` runs as root. The individual containers
do not, they run as local users inside the container: With the exception of
eth2.0-deposit-cli, because it has no network connection and does not run
as an ongoing service.

In the interest of readability, warnings about the dangers of running
eth2 validators have been moved to [RECOMMENDATIONS.md](RECOMMENDATIONS.md).
That file also contains comments on key security. Just know that funds can be
lost unless precautions are taken.

This README has some [troubleshooting commands](#troubleshooting).

## Install prerequisites

This project relies on docker and docker-compose, and git to bring the
project itself in. It has been tested on Linux and Windows 10, and is
expected to work on MacOS. Notes on how to install prerequites for
these systems are in [PREREQUISITES.md](PREREQUISITES.md).

Once they are met, navigate to a convenient directory that you
have write access to - your $HOME is fine - and pull this repo
via git:<br />
`git clone https://github.com/eth2-educators/eth2-docker.git`,
then `cd eth2-docker` into the newly created directory.

## Create an eth2 wallet and validator keystore and deposit files

You will deposit eth to the deposit contract, and receive locked eth2 in turn.<br />
[RECOMMENDATIONS.md](RECOMMENDATIONS.md) has comments on key security.

Edit the `.env` file to set the number of validators you wish to run. The default
is just one (1) validator.

This command will get you ready to deposit eth:<br />
`sudo docker-compose run deposit-cli`

The created files will be in the directory `.eth2/validator_keys` in this project.
This is also where you'd place your own keystore files if you already have some for import.

### You brought your own keys

They go into `.eth2/validator_keys` in this project directory, not directly under `$HOME`.

## Choose a client

There is a default file which runs lighthouse with local geth. If you are good with the default, just run with that.

You'll be copying from the directory `clients` to the file `docker-compose.yml` in this directory. Current options are:
- [Lighthouse](#lighthouse), `cp clients/lh.yml ./docker-compose.yml`
- [Prysm](#prysm), `cp clients/prysm.yml ./docker-compose.yml`

If you are going to use a 3rd-party eth1chain provider, edit `.env` and set either `LH_ETH1_NODE` or `PRYSM_ETH1_NODE` to
point to your provider, and use the `eth2-3rd` target once you have imported keys and are ready.

## Lighthouse 

### Create a validator wallet by importing validator keys

**Warning** Import your validator key(s) to only *one* client.

Import the validator key(s) to the Lighthouse validator client:

`sudo docker-compose run lh-validator-import`

If you specify the password during import, it'll be available to the client every
time it starts. If you do not, you'll need to be present to start the
validator and start it interactively. Determine your own risk profile.

### Start the client

To start the Lighthouse client, both beacon and validator, with local geth:

```
sudo docker-compose up -d eth2
```

Instead, if you are using a 3rd-party eth1chain, make sure that `LH_ETH1_NODE` in the file `.env` is pointing to it.

To start the Lighthouse client, both beacon and validator, with 3rd party eth1chain:

```
sudo docker-compose up -d eth2-3rd
```

If, however, you chose not to store the wallet password locally, bring the services
up individually instead:

With local geth:

```
sudo docker-compose up -d geth lh-beacon
```

Or with 3rd party eth1chain:
```
sudo docker-compose up -d lh-beacon

```

Then "run" the validator so it can prompt you for input:
```
sudo docker-compose run lh-validator
```

After providing the wallet password, use the key sequence Ctrl-p Ctrl-q to detach
from the running container.

## Prysm

### Create a validator wallet by importing validator keys

**Warning** Import your validator key(s) to only *one* client.

Import the validator key(s) to the Prysm validator client:

`sudo docker-compose run prysm-validator-import`

You will be asked to provide a wallet directory. Use `/var/lib/prysm`.

You will be asked to provide a new wallet password. 

If you choose to store the password during import, it'll be available to the client every
time it starts. If you do not, you'll need to be present to start the
validator and start it interactively. Determine your own risk profile.

### Start the client

The Prysm client requires copying in a file, see the [client choice](#choose-a-client) section.

Note that the Prysm client will find its external IP, but this project currently assumes
that IP is static. You can restart the container, possibly via crontab, with
`docker-compose restart prysm-beacon` if your IP is dynamic. 
Work to support dynamic DNS would also be welcome.

To start the Prysm client, both beacon and validator, with local geth:

```
sudo docker-compose up -d eth2
```

Instead, if you are using a 3rd-party eth1chain, make sure that `PRYSM_ETH1_NODE` in the file `.env` is pointing to it.
To start the Prysm client, both beacon and validator, with 3rd party eth1chain:

```
sudo docker-compose up -d eth2-3rd
```

If, however, you chose not to store the wallet password locally, bring the services
up individually instead:

With local geth:
```
sudo docker-compose up -d geth prysm-beacon
```

Or with 3rd-party eth1chain:
```
sudo docker-compose up -d prysm-beacon
```

Then "run" the validator so it can prompt you for input:
```
sudo docker-compose run prysm-validator
```

After providing the wallet password, use the key sequence Ctrl-p Ctrl-q to detach
from the running container.

## Depositing

Once you are ready, you can send eth to the deposit contract by using
the `.eth2/validator_keys/deposit_data-TIMESTAMP.json` file at the [Medalla launchpad](https://medalla.launchpad.ethereum.org/).

## Autostart the client on boot

Docker Desktop for Windows 10 and MacOS may do this automatically, TBD.

For Linux systems that use systemd, e.g. Ubuntu, you'd create a systemd
service. 

- Copy the file: `sudo cp sample-systemd /etc/systemd/system/eth2.service`
- Edit the file `/etc/systemd/system/eth2.service`
- Adjust the `WorkingDirectory` to the directory you stored the project in.
- Adjust the `ExecStart` to use the right target - `eth2-3rd` if you don't run geth
- Adjust the path to `docker-compose` to be right for your system, see `which docker-compose`
- Test the service: `sudo systemctl daemon-reload`, `sudo systemctl start eth2`, check `docker ps` to
see all expected containers are up
- Enable the service: `sudo systemctl enable eth2`

## Monitor the client

Monitoring the logs of the client is useful for troubleshooting
and to judge the amount of time left before the beacon and geth nodes
are fully synchronized.

To see a list of running containers:

```
sudo docker ps
```

To see the logs of a container:

```
sudo docker logs -f CONTAINERNAME
```

or

```
sudo docker-compose logs -f SERVICENAME
```

## Update a client

This project does not monitor client versions. It is up to you to decide that you
are going to update a component. When you are ready to do so, the below instructions
show you how to.

### Geth

Run:<br />
`sudo docker-compose build --no-cache geth`

Then stop, remove and start geth:<br />
`sudo docker-compose stop geth && sudo docker-compose rm geth`<br />
`sudo docker-compose up -d geth`

### Lighthouse

lh-beacon and lh-validator share the same image, we only need to rebuild one.

Run:<br />
`sudo docker-compose build --no-cache lh-beacon`

Then restart the client:<br />
`sudo docker-compose down && sudo docker-compose up -d eth2`

If you did not provide the wallet password to the container, or you are not using a local geth
node, come up [more manually](#start-the-client) instead.

### Prysm

prysm-beacon and prysm-validator share the same image, we only need to rebuild one.

Run:<br />
`sudo docker-compose build --no-cache prysm-beacon`

Then restart the client:<br />
`sudo docker-compose down && sudo docker-compose up -d eth2`

If you did not provide the wallet password to the container, or you are not using a local geth
node, come up [more manually](#start-the-client-1) instead.

# Troubleshooting

A few useful commands if you run into issues.

`docker-compose stop servicename` brings a service down, for example `docker-compose stop lh-validator`.<br />
`docker-compose down` will stop the entire stack.<br />
`docker-compose up -d servicename` starts a single service, for example `docker-compose up -d lh-validator`.
The `-d` means "detached", not connected to your input session.<br />
`docker-compose run servicename` starts a single service and connects your input session to it. Use the Ctrl-p Ctrl-q
key sequence to detach from it again.

`docker ps` lists all running services, with the container name to the right.<br />
`docker logs containername` shows logs for a container, `docker logs -f containername` scrolls them.<br />
`docker exec -it containername /bin/bash` will connect you to a running service in a bash shell. The geth service doesn't have a shell.<br />

If a service is continually restarting and you want to bring up its container manually, so you can investigate, first bring everything down:<br />
`docker-compose down`, tear down everything first.<br />
`docker ps`, make sure everything is down.<br />

**HERE BE DRAGONS** You can totally run N copies of an image manually and then successfully start a validator in each and get yourself slashed.
Take extreme care.

Once your stack is down, to run an image and get into a shell, without executing the client automatically:<br />
`docker run -it --entrypoint=/bin/bash imagename`, for example `docker run -it --entrypoint=/bin/bash lighthouse`.<br />
You'd then run Linux commands manually in there, you could start components of the client manually. There is one image per client,
the client images currently supplied are `lighthouse` and `prysm`.<br />
`docker images` will show you all images.

# Guiding principles:

- Reduce the attack surface of the client where this is feasible. Not
  all clients lend themselves to be statically compiled and running
  in "scratch"
- Guide users to good key management as much as possible
- Create something that makes for a good user experience and guides people new to docker and Linux as much as feasible

LICENSE: MIT
