Docker container for eth2.0-deposit-cli

Pass UID during build if you are not using docker-compose

The following assumes Ubuntu, hence sudo to run docker. If that's not necessary in your environment,
just leave sudo off the command and run directly as the logged-in user.

You'd run this from the docker-compose one level up. To test build here:

`sudo docker build -t eth2.0-deposit-cli --build-arg USER=depcli --build-arg UID=$UID .`

Create a directory to hold the created keys:

`mkdir -p $HOME/.eth2`

You can then run this, assuming you have a `~/.eth2/` directory, and you want one validator on the
medella testnet:

`sudo docker run -it -v $HOME/.eth2:/var/lib/depcli eth2.0-deposit-cli`

Here is an example of running it to create 10 validators:

`sudo docker run -it -v $HOME/.eth2:/var/lib/depcli -e "numvals=10" eth2.0-deposit-cli`

**Critical**

Make sure to write down your mnemonic and keep it in a safe place.
You will find your keys in $HOME/.eth2/validator_keys.
See the README.md one directory up for more on key security.

Prune build images - saves space if no further builds are likely:

`sudo docker system prune -f`
