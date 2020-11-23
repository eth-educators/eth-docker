In the absence of a proper test script, a few quick notes on a test sequence that
should show functionality.

Prep that's not client specific:
- `cp default.env .env`, adjust LOCAL_UID and ports as needed
- `sudo docker volume rm $(sudo docker volume ls -q | grep eth2-docker)`, wipe volumes from last pass,
   assuming that `eth2-docker` is the directory we are testing in.


For each client:
- Start with the most "complete" stack to test full build
- Set `COMPOSE_FILE` in `.env` to full client stack, set `ETH1_NODE` to geth.
- `sudo docker ps`, make sure nothing is left running
- Build the client stack:<br />
  `sudo docker-compose build`
- There likely is a cached version of the client, let's make sure it's the latest.
  `sudo docker-compose build --no-cache beacon`
- Coffee, tea, hall sword fights :)
- `rm .eth2/validator_keys/*`, wipe keys from last pass
- `sudo docker-compose run deposit-cli`, create keys
- `sudo docker-compose run validator-import`, import keys
- `sudo docker-compose up -d eth2`, observe that they come up in order: geth->beacon->validator
- Check running and logs and see that everything is chill, watch especially for missed connections:
  - `sudo docker ps`
  - `sudo docker-compose logs geth`
  - `sudo docker-compose logs beacon`
  - `sudo docker-compose logs validator`
- `sudo docker-compose down`
- Set `ETH1_NODE` to infura.io URL, remove `geth.yml` from `COMPOSE_FILE`, and test again
  from just after validator import, just without geth.

Specific to systemd:
- Start the service manually
- Check everything is up and happy
- Stop the service manually
- Check everything is down
- Enable the service
- Reboot
- Check that everything came back up as expected
