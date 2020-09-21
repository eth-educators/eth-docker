# eth2-docker v0.04
Unofficial and experimental docker build instructions for eth2 clients

This project builds clients from source. A similar workflow for
binary images is a TODO, as long as it does not duplicate work
by client teams.

Currently included clients:
- Lighthouse, with local geth
- Prysm, with local geth

#USAGE

A file 'default.env' is provided and needs to be copied to '.env'.
If this is not done, running docker-compose will fail.
After copying the file, you **must** adjust the contents to your environment.
Specifically, set the first entry `DEPCLI_UID` to your UID if you are running
this on Linux. You can find your UID with `echo $UID`.

## Install prerequisites

Installation prerequisites are towards the bottom of this file.

##Create an eth2 wallet and deposit files

You will deposit eth to the deposit contract, and receive locked eth2 in turn.
The security of this wallet is **critical**. If it is compromised, you will lose
your balance. Please make sure you understand eth2 staking before you continue.

When you create the wallet and deposit files, write down your mnemonic and
choose a cryptographically strong password for your keystores. Something long
and not used anywhere else, ideally randomized by a generator.

Edit the `.env` file to set the number of validators you wish to run. The default
is just one (1) validator.

With that said, this command will get you ready to deposit eth:
`sudo docker-compose run deposit-cli`

The created files will be in the directory `.eth2` in this project.
Please see the file `KEY-SECURITY.md` in this project for some notes on
key security.

##Verify that the mnemonic works

Crucial step, TBD.

##Slashing risks

If you run two validators with the same validator key(s), you are going to get
"slashed": A large penalty will be levied against you and your validators will
be forced to exit.

This can only happen if you import the same validator keys into multiple clients
and then start those clients.

While this project gives you the freedom to shoot yourself in the foot like that,
**please do not**. Choose one client and run that, and only that, client.

##Create a wallet by importing validator keys

###Lighthouse

Once both your withdrawal key (mnemonic) and validator key(s) (`keystore-m_ID.json` file(s))
are secured offline, and **not** before, import the validator key(s) to the Lighthouse
validator client:

`sudo docker-compose run lh-validator-import`

If you specify the password here, it'll be available to the client every
time it starts. If you do not, you'll need to be present to start the
validator and start it interactively. Determine your own risk profile.

###Prysm

**Warning** Import your validator key(s) to only *one* client.

Once both your withdrawal key (mnemonic) and validator key(s) (`keystore-m_ID.json` file(s))
are secured offline, and **not** before, import the validator key(s) to the Prysm
validator client:

`sudo docker-compose run prysm-validator-import`

You will be asked to provide a wallet directory. Use `/var/lib/prysm`.

You will be asked to provide a new wallet password. Make sure it is unique
and strong, and: Keep it safe!

If you choose to store the password here, it'll be available to the client every
time it starts. If you do not, you'll need to be present to start the
validator and start it interactively. Determine your own risk profile.

##Before depositing

You likely want to wait to deposit your eth until you can see in the logs
that the eth1 node (e.g. geth) is synchronized and the eth2 beacon node
is fully synchronized, which happens after that. This takes hours on
testnet and could take days on mainnet.

If you deposit before your client stack is fully synchronized and running,
you risk getting penalized for being offline. The offline penalty during
the first 5 months of mainnet will be roughly 0.13% of your deposit per
week.

Once you are ready, you can send eth to the deposit contract by using
the `deposit_data-TIMESTAMP.json` file at the [Medalla launchpad](https://medalla.launchpad.ethereum.org/).

##Start the client

Before you start any clients, make sure you have the validator set up with a wallet,
and you secured your withdrawal key (mnemonic) as well as your validator key(s)
(`keystore-m_ID.json` file(s)).

Then, and **only** then:

###Lighthouse

To start the lighthouse client, both beacon and validator, with local geth:

```
sudo docker-compose up -d lighthouse
```

If, however, you chose not to store the wallet password locally, bring the services
up individually instead:

```
sudo docker-compose up -d geth lh-beacon
sudo docker-compose run lh-validator
```

After providing the wallet password, use the key sequence Ctrl-p Ctrl-q to detach
from the running container.

###Prysm

Note that the Prysm client will find its external IP, but this repo assumes
that IP is static. You can restart the container, possibly via crontab, with
`docker-compose restart prysm-beacon` if your IP is dynamic. 
Work to support dynamic DNS would also be welcome.

To start the Prysm client, both beacon and validator, with local geth:

```
sudo docker-compose up -d prysm
```

If, however, you chose not to store the wallet password locally, bring the services
up individually instead:

```
sudo docker-compose up -d geth prysm-beacon
sudo docker-compose run prysm-validator
```

After providing the wallet password, use the key sequence Ctrl-p Ctrl-q to detach
from the running container.

##Monitor the client

To see a list of running containers:

```
sudo docker ps
```

To see the logs of a container:

```
sudo docker logs -f CONTAINERNAME
```

or

``
sudo docker-compose logs -f SERVICENAME
```

##Ubuntu Prerequisites

To run the client with defaults, assuming an Ubuntu host:

```
sudo apt update && sudo apt install docker docker-compose git
cd
git clone https://github.com/eth2-educators/eth2-docker.git
cd eth2-docker
cp default.env .env
```

Other distributions are expected to work as long as they support
git, docker, and docker-compose.

##Windows 10 Prerequisites

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/win), and [Python 3](https://www.python.org/downloads/windows/). Note yyou can also type `python3` into a Powershell window and it will bring you to the Microsoft Store for a recent Python 3 version.

Docker Desktop can be used with the WSL2 backend if desired, or without it.

You will run the docker-compose and docker commands from Powershell. You do not need `sudo` in front of those commands.

##MacOS Prerequisites

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/mac) and [Python 3](https://www.python.org/downloads/mac-osx/).
MacOS has not been tested, if you have the ability to, please get in touch via the ethstaker Discord.

##Update a client

This project does not monitor client versions. It is up to you to decide that you
are going to update a component. When you are ready to do so, the below instructions
show you how to.

###Geth

Run:
`sudo docker-compose build --no-cache geth`

Then restart geth:
`sudo docker-compose restart geth`

###Lighthouse

lh-beacon and lh-validator share the same image, we only need to rebuild one.

Run:
`sudo docker-compose build --no-cache lh-beacon`

Then restart the client:
`sudo docker-compose down && sudo docker-compose up -d lighthouse`

If you did not provide the wallet password to the container, come up more manually instead.

###Prysm

prysm-beacon and prysm-validator share the same image, we only need to rebuild one.

Run:
`sudo docker-compose build --no-cache prysm-beacon`

Then restart the stack:
`sudo docker-compose down && sudo docker-compose up -d prysm`

If you did not provide the wallet password to the container, come up more manually instead.

#Guiding principles:

- Reduce the attack surface of the client where this is feasible. Not
  all clients lend themselves to be statically compiled and running
  in "scratch"
- Guide users to good key management as much as possible
- Create something that makes for a good user experience and guides people new to docker and Linux as much as feasible

LICENSE: MIT
