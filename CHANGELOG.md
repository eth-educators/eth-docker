# Changelog for eth2-docker project

## Updating the project

To update the components of the project, run from within the project
directory (`cd ~/eth2-docker` by default):

* `git pull`
* `cp .env .env.bak && cp default.env .env`
* Adjust contents of new `.env`, use `.env.bak` for guidance (LOCAL_UID
  and COMPOSE_FILE are the most common variables that may need to be adjusted)
* `sudo docker-compose build --pull` if you are using binary builds, the default
* `sudo docker-compose build --pull --no-cache beacon` **only** if you are using source builds, then
  run `sudo docker-compose build -pull` to update the rest of the "stack"
* `sudo docker-compose down`
* !! If coming from Lighthouse v0.2.x, make changes as per notes for [v0.1.6](#v016-2020-10-09)
* !! If coming from Prysm alpha.29 or earlier, make changes as per notes for [v0.1.7](#v017-2020-10-15)
* `sudo docker-compose up -d eth2`

## v0.2.5.1 2021-01-09

* Changed sample-systemd to start services after containerd restart, which helps them survive Ubuntu auto-update

## v0.2.5 2021-01-07

* Support for Nethermind 1.10.x-beta source builds

## v0.2.4.2 2020-12-24

* Support for Lighthouse v1.0.5

## v0.2.4.1 2020-12-16

* Support for Pyrsm fallback eth1 nodes

## v0.2.4 2020-12-07

* Support for new metanull dashboard
* Initial support for ynager dashboard, eth price not working yet

## v0.2.3.3 2020-12-06

* More time for OpenEthereum to shut down
* Added documentation on how to restrict access to Grafana when using a VPS

## v0.2.3.2 2020-12-01

* Added max peer values to `default.env`. Make sure to transfer this from `default.env` to your `.env`

## v0.2.3.1 2020-11-30

* Changed Geth shutdown to SIGINT with 2 min timeout so that Geth does not need to resync after
  `sudo docker-compose down`. In testing Geth took ~50s to shut down on my entry level server.

## v0.2.3 2020-11-29

* First attempt at Geth Grafana metrics. Does not work for eth1-standalone currently
* Removed Nethermind manual barrier, as it is now part of Nethermind's default mainnet config

## v0.2.2 2020-11-27

* Lighthouse v1.0.1 validator metrics supported

## v0.2.1 2020-11-24

* Support for Besu eth1 client
* Fixed an issue with Nimbus log file
* Removed CORS settings for eth1, for now
* Tightened hosts values for Geth and Besu

## v0.2.0 2020-11-24

* Support for Lighthouse v1.0.0
* Change default tags for Lighthouse and Prysm to track v1.0.0 release

## v0.1.8.8 2020-11-20

* Initial attempt at Besu integration. While Besu builds, Lighthouse doesn't communicate with it.
  Strictly for testing.

## v0.1.8.7 2020-11-19

* Integrated community dashboard for lighthouse, teku, and nimbus.

## v0.1.8.6 2020-11-16

* Nethermind added as eth1 option, thanks to adrienlac. Not stable in testing.
* First attempt at binary option for all but eth2.0-deposit-cli

## v0.1.8.5 2020-11-11

* Added option to run eth1 node exposed to the host on RPC port

## v0.1.8.4 2020-11-08

* Updated grafana image to change all occurrences of `job="beacon"` to `job=beacon_node` in the metanull dashboard.
* Updated grafana image to rename prysm dashboard titles.

## v0.1.8.3 2020-11-07

* Auto configure Grafana with prometheus datasource.
* Auto Add `Metanull's Prysm Dashboard JSON` to Grafana
* Auto Add `Prysm Dashboard JSON` to Grafana
* Auto Add `Prysm Dashboard JSON for more than 10 validators` to Grafana

## v0.1.8.2 2020-11-06

* Add OpenEthereum eth1 client option

## v0.1.8.1 2020-11-05

* Experimental Prysm slasher - thank you @danb!
* Fixed Prysm Grafana which got broken when pulling out Prysm Web

## v0.1.8 2020-11-04

* eth2.0-deposit-cli 1.0.0 for Ethereum 2.0 main net
* First stab at Lighthouse voluntary exit
* More conservative build targets for Lighthouse, Prysm, Teku, and Geth: Latest release tag instead of `master`

## v0.1.7.5 2020-10-29

* validator-import for Teku now understands Prysm export

## v0.1.7.4 2020-10-29

* Support experimental Prysm Web UI

## v0.1.7.3 2020-10-27

* Prysm change to remove creation of new protection DB, Prysm no longer has this flag

## v0.1.7.2 2020-10-23

* Prysm changes to allow creation of new protection DB and remove experimental web support while it is in flux

## v0.1.7.1 2020-10-16

* Prysm renamed `accounts-v2` to `accounts`, keeping pace with it

## v0.1.7 2020-10-15

* Added "validator-voluntary-exit" to Prysm, see [readme](README.md#addendum-voluntary-client-exit)
* Default restart policy is now "unless-stopped" and can be changed via `.env`
* Preliminary work to support Prysm Web UI, not yet functional
* Changed testnet parameter for Prysm to conform with alpha.29
* Use `--blst` with Prysm by default for faster sync speed
* Handles Terms Of Service for Prysm, user is prompted during validator-import, and choice is remembered
* If you are upgrading this project and you are using Prysm, please run `sudo docker-compose run validator`
  and accept the terms of use. You can then Ctrl-C that process and start up normally again. This step
  is not necessary if you are starting from scratch.

## v0.1.6 2020-10-09

* Support for Lighthouse v0.3.0, drop support for v0.2.x
  * Please note that Lighthouse v0.3.x makes a breaking change to the beacon
    db. You will need to sync again from scratch, after building the new v0.3.0
    beacon image. You can force this with 
    `sudo docker-compose down`, `sudo docker volume rm eth2-docker_lhbeacon-data`
    (adjust to your directory path if you are not in `eth2-docker`, see
    `sudo docker volume ls` for a list).
  * Likewise, the location of the validator keystore has changed. The fastest way
    to resolve this involves importing the keystore from scratch:
    `sudo docker volume rm eth2-docker_lhvalidator-data` (as before, adjust for
    your directory), and then import the keystore(s) again with
    `sudo docker-compose run validator-import`. Your keystore(s) need to be in
    `.eth2/validator_keys` inside the project directory for that.
  * When you have completed the above steps, bring up Lighthouse with
    `sudo docker-compose up -d eth2` and verify that the beacon started syncing
    and the validator found its public key(s) by observing logs:<br />
    `sudo docker-compose logs -f beacon` and `sudo docker-compose logs validator | head -30`,
    and if you wish to see ongoing validator logs, `sudo docker-compose logs -f validator`.
  * The beacon will sync from scratch, which will take about half a day. Your
    validator will be marked offline for that duration.
