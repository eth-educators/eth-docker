# eth2-docker v0.01
Unofficial and experimental docker build instructions for eth2 clients

Caveat: 
- The directory .eth2/lighthousevalidator-data needs to be chown'd to the UID of the lighthouse
  user. This is not currently automated, please run `sudo chown -R 10001:10001 .eth2` assuming
  default UID for the ligthhouse user. This is a large TODO around secrets management.
- There is no provision made at all for wallet management presently, or even
  wallet creation. This is the major TODO before this effort becomes generally
  useful. Validators are expected to fail startup because of this. 
  The current solution is to run the validator docker image with a command to create
  or import a wallet before starting the entire stack.
- Example of creating a wallet and validator account on Lighthouse before starting the full stack:
  ```
  sudo docker-compose run lh-validator account wallet create --name <WALLET_NAME> --password-file <WALLET_PASSWORD_PATH>
  sudo docker-compose run lh-validator account validator create --wallet-name <WALLET_NAME> --wallet-password <WALLET_PASSWORD_PATH> --at-most <VALIDATOR_COUNT>
  ```
  
Currently supported clients:
- Lighthouse, with local geth

A file 'default.env' is provided and needs to be copied to '.env'.
If this is not done, running docker-compose will fail.
After copying the file, you may adjust the contents to your environment.

To run the client with defaults, assuming an Ubuntu host:

```
sudo apt update && sudo apt install docker docker-compose git
cd
git clone https://github.com/eth2-educators/eth2-docker.git
cd eth2-docker
cp default.env .env
```

To start the lighthouse client, both beacon and validator, with local geth:

```
sudo docker-compose up -d lighthouse
```

To see a list of running containers:

```
sudo docker ps
```

To see the logs of a container:

```
sudo docker logs CONTAINERNAME
```

Running docker-compose commands without the requirement for sudo:

```
sudo gpasswd -a YOURUSERNAME docker
newgrp docker 
```

Guiding principles:
- Reduce the attack surface of the client where this is feasible. Not
  all clients lend themselves to be statically compiled and running
  in "scratch"
- Implement good secrets management, avoid clear-text secrets
- Do not re-invent the wheel: Binary distributions are already handled
  well by their respective client teams

LICENSE: MIT
