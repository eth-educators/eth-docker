In the absence of a proper test script, a few quick notes on a test sequence that
should show functionality.

Prep that's not client specific:
- `sudo docker volume rm $(docker volume ls -q | grep eth2-docker)`
- `cp default.env .env`, adjust LOCAL_UID and ports as needed

For each client:
- `cp clients/CLIENT.yml docker-compose.yml`
- `sudo docker ps`, make sure nothing is left running
- `sudo docker-compose build --no-cache deposit-cli geth CLIENT-beacon`
- Coffee, tea, hall sword fights :)
- `rm .eth2/validator_keys/*`, wipe keys from last pass
- `sudo docker-compose run deposit-cli`, create keys
- `sudo docker-compose run CLIENT-validator-import`, import keys
- `sudo docker-compose up -d eth2`
- Check running and logs and see that everything is chill:
  - `sudo docker ps`
  - `sudo docker-compose logs geth`
  - `sudo docker-compose logs CLIENT-beacon`
  - `sudo docker-compose logs CLIENT-validator`
- `sudo docker-compose down`
- Edit `.env` to set the ETH1_NODE to infura.io
- `sudo docker-compose up -d eth2-3rd`
- Check running and logs like above, minus geth
- `sudo docker-compose down`
- Edit `.env` to set the ETH1_NODE back to geth for the next test round 

Those deposit-cli steps may seem redundant, they test that each client.yml
has the correct settings to build deposit-cli and geth.

Specific to systemd:
- Start the service manually
- Check everything is up and happy
- Stop the service manually
- Check everything is down
- Enable the service
- Reboot
- Check that everything came back up as expected
