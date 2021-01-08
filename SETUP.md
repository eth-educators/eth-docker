# Initial setup

If you haven't already, please see [prerequisites](PREREQUISITES.md) and meet them for your OS.
This file steps you through client choice as well as some basic host security steps on Linux.

## Non-root user on Linux

If you are logged in as root and do not have a non-root user already, create a non-root user 
with your `USERNAME` of choice to log in as, and give it sudo rights. `sudo` allows you to 
run commands `as root` while logged in as a non-root user. 

This step may be needed on a VPS, and is not typically needed on a local fresh install of Ubuntu,
as Ubuntu creates a non-root user by default.

```
adduser USERNAME
```

You will be asked to create a password for the new user, among other things. Then, give the new user
administrative rights by adding it to the `sudo` group.

```
usermod -aG sudo USERNAME
```

Optional: If you used SSH keys to connect to your Ubuntu instance via the root user you
will need to [associate the new user with your public key(s)](#ssh-key-authentication-with-linux).

## Static IP

You'll want a static IP address for your server, one that doesn't change. This allows easier
port-forwarding for your Ethereum client peering, and easier management and remote access for you:
You do not need to find a changing server address. You can do set an unchanging IP address a few
different ways.

- You can configure your router to use a [DHCP reservation](https://homenetworkadmin.com/dhcp-reservation/).
How to do this depends on your router.
- You could instead choose an IP address *outside* your DHCP range and [configure it as a static IP](https://linuxhint.com/setup_static_ip_address_ubuntu/).
In Ubuntu Desktop this is done through Network Manager from the UI, and in Ubuntu Server you'll handle it
from CLI via netplan. Check your router configuration to see where your DHCP range is, and what
values to use for default gateway and DNS.
## "Clone" the project

From a terminal and logged in as the user you'll be using from now on, and assuming
you'll be storing the project in your `$HOME`, run:

```
cd ~ && git clone https://github.com/eth2-educators/eth2-docker.git && cd eth2-docker
```

You know this was successful when your prompt shows `user@host:~/eth2-docker`

> Note: All work will be done from within the `~/eth2-docker` directory.
> All commands that have you interact with the "dockerized" client will
> be carried out from within that directory.

## Client choice

Please choose:
* The eth2 client you wish to run
  * Lighthouse
  * Prysm
  * Teku
  * Nimbus
* Your source of eth1 data
  * geth
  * besu - has not been tested extensively by this team. Feedback welcome.
  * nethermind - pruning in beta. Feedback welcome.
  * openethereum - testing mainly, DB corruption resolved.
  * 3rd-party
* Whether to run a slasher (experimental for Prysm)
* Whether to run a grafana dashboard for monitoring

> Note: Teku is written in Java, which makes it memory-hungry. In its default configuration, you may
> want a machine with 24 GiB of RAM or more. See `.env` for a parameter to restrict Teku to 6 GiB of heap. It
> may still take more than 6 GiB of RAM in total.

First, copy the environment file.<br />
`cp default.env .env`

> This file is called `.env` (dot env), and that name has to be exact. docker-compose
> will otherwise show errors about not being able to find a `docker-compose.yml` file,
> which this project does not use.
 
Then, adjust the contents of `.env`. On Ubuntu Linux, you can run `nano .env`.
- If you are on Linux, **adjust `LOCAL_UID` to the UID of the logged-in user**. 
`echo $UID` will show it to you. It is highly recommended to run as a non-root
user on Linux. On [Debian](https://devconnected.com/how-to-add-a-user-to-sudoers-on-debian-10-buster/)
you may need to install `sudo` and add your user to the `sudoers` group. Ubuntu
has that functionality built-in.

> **Important**: The step above needs to be completed before the client is
> built. Use the same user to configure, build and run the client. If the
> UID in `.env` does not match the UID of the user, then you will get
> permissions errors during use.

- Set the `COMPOSE_FILE` entry depending on the client you are going to run,
and with which options. See below for available compose files. Think of this as
blocks you combine: One ethereum 2 client, optionally one ethereum 1 node, optionally reporting.
- If you are going to use a 3rd-party provider as your eth1 chain source, set `ETH1_NODE` to that URL.
  Look into [Alchemy](https://alchemyapi.io) or see [how to create your own Infura account](https://status-im.github.io/nimbus-eth2/infura-guide)
- For Lighthouse, you can set `ETH1_NODE` to a comma-separated list, for example `http://eth1:8545,https://<alchemy-url>`
  would use a local eth1 first, and fail back to Alchemy when it does not respond.
- Adjust ports if you are going to need custom ports instead of the defaults. These are the ports
exposed to the host, and for the P2P ports to the Internet via your firewall/router.
- Set the `NETWORK` variable to either "mainnet" or a test network such as "pyrmont"
- If using geth as the eth1 node, comment out the `GETH1_NETWORK` variable, to use the main net, or set it to a test network such as "--goerli",
  with the two dashes.
- With other eth1 nodes, the `ETH1_NETWORK` variable serves the same function. It can be set to `mainnet` to use the main eth1 network.
- Set the `GRAFFITI` string if you want a specific string.

### Client compose files

Set the `COMPOSE_FILE` string depending on which client you are going to use. Add optional services like
geth with `:` between the file names.
- `lh-base.yml` - Lighthouse
- `prysm-base.yml` - Prysm
- `teku-base.yml` - Teku
- `nimbus-base.yml` - Nimbus
- `geth.yml` - local geth eth1 chain node
- `besu.yml` - local besu eth1 chain node - has not been tested extensively by this team. Feedback welcome.
- `nm.yml` - local nethermind eth1 chain node - pruning in beta. Feedback welcome.
- `oe.yml` - local openethereum eth1 chain node - testing mainly, DB corruption resolved.
- `eth1-shared.yml` - makes the RPC port of the eth1 node available from the host, for using the eth1 node with other nodes or with Metamask. To be used alongside one of the eth1 yml files. **Not encrypted**, do not expose to Internet.
- `eth1-standalone.yml` - like eth1-shared but for running *just* eth1, instead of running it alongside a beacon node in the same "stack". To be used alongside one of the eth1 yml files. Also not encrypted, not meant for a fully distributed setup quite yet.
- `prysm-slasher.yml` - Prysm experimental Slasher which helps secure the chain and may result in additional earnings. The experimental slasher can lead to missed attestations do to the additional resource demand.
- `lh-grafana.yml` - grafana dashboard for Lighthouse
- `prysm-grafana.yml` - grafana dashboard for Prysm. Not encrypted, do not expose to Internet.
- `prysm-web.yml` - Prysm experimental Web UI and Grafana dashboard. Not encrypted, do not expose to Internet. **Mutually exclusive** with `prysm-grafana.yml`
- `nimbus-grafana.yml` - grafana dashboard for Nimbus
- `teku-grafana.yml` - grafana dashboard for Teku
- `geth-grafana.yml` - grafana dashboard for Geth, to be combined with one of the client dashboards: Does not work standalone currently. Example `COMPOSE_FILE=lh-base.yml:geth.yml:lh-grafana.yml:geth-grafana.yml`

For example, Lighthouse with local geth and grafana:
`COMPOSE_FILE=lh-base.yml:geth.yml:lh-grafana.yml`

> See [WEB](WEB.md) for notes on using the experimental Prysm Web UI

In this setup, clients are isolated from each other. Each run their own validator client, and if eth1
is in use, their own eth1 node. This is perfect for running a single client, or multiple isolated
clients each in their own directory.

If you want to run multiple isolated clients, just clone this project into a new directory for
each. This is great for running testnet and mainnet in parallel, for example.

> Nimbus and Nethermind/Besu have interop issues as of 11/24/2020 when using eth2-docker. Use Geth or OpenEthereum instead for now.
> Help with tracking root cause down greatly appreciated.

### Prysm Slasher   
Running [slasher](https://docs.prylabs.network/docs/prysm-usage/slasher/) is an optional client compose file, but helps secure the chain and may result in additional earnings,
though the chance of additional earnings is low initially whistleblower rewards have not been implemented yet.

> Slasher can be a huge resource hog during times of no chain finality, which can manifest as massive RAM usage. Please make sure you understand the risks of this, 
> especially if you want high uptime for your beacon nodes. Slasher places significant stress on beacon nodes when the chain has no finality, and might be the reason
> why your validators are underperforming if your beacon node is under this much stress.

## Firewalling

You'll want to enable a host firewall. You can also forward the P2P ports of your eth1 and eth2
nodes for faster peer acquisition.

These are the relevant ports. docker will open eth2 node ports and the grafana port automatically,
please make sure the grafana port cannot be reached directly. If you need to get to grafana remotely,
an [SSH tunnel](https://www.howtogeek.com/168145/how-to-use-ssh-tunneling/) is a good choice.

For a VPS/cloud setup, please take a look at notes on [cloud security](CLOUD.md). You'll want to
place ufw "in front of" Docker if you are using Grafana or a standalone eth1 (Ethereum PoW) client,
and if your cloud provider does not offer firewall rules for the VPS.

Ports that I mention can be "Open to Internet" can be either forwarded
to your node if behind a home router, or allowed in via the VPS firewall.

> Opening the P2P ports to the Internet is optional. It will speed up peer acquisition, which
> can be helpful. To learn how to forward your ports in a home network, first verify
> that you are [not behind CGNAT](https://winbuzzer.com/2020/05/29/windows-10-how-to-tell-if-your-isp-uses-carrier-grade-nat-cg-nat-xcxwbt/).
> Then look at [port-forwarding instructions](https://portforward.com/) for your specific router/firewall. 

- 30303 tcp/udp - local eth1 node P2P. Open to Internet.
- 9000 tcp/udp - Lighthouse beacon node P2P. Open to Internet.
- 13000/tcp - Prysm beacon node P2P. Open to Internet.
- 12000/udp - Prysm beacon node P2P. Open to Internet.
- 9000 tcp/udp - Teku beacon node P2P. Open to Internet. Note this is the same default port as Lighthouse.
- 9000 tcp/udp - Nimbus beacon node P2P. Open to Internet. Note this is the same default port as Lighthouse.
- 3000/tcp - Grafana. **Not** open to Internet, allow locally only. It is insecure http.
- 22/tcp - SSH. Only open to Internet if this is a remote server (VPS). If open to Internet, configure
  SSH key authentication.

On Ubuntu, the host firewall `ufw` can be used to allow SSH traffic. docker bypasses ufw and opens additional
ports directly via "iptables" for all ports that are public on the host.

* Allow SSH in ufw so you can still get to your server, while relying on the default "deny all" rule.
  * `sudo ufw allow OpenSSH` will allow ssh inbound on the default port. Use your specific port if you changed
    the port SSH runs on.
* Check the rule you created and verify that you are allowing SSH, on the port you are running it on.
  You can **lock yourself out** if you don't allow your SSH port in. `allow OpenSSH` is sufficient
  for the default SSH port.
  * `sudo ufw show added`
* Enable the firewall and see numbered rules once more
  * `sudo ufw enable`
  * `sudo ufw status numbered`

> There is one exception to the rule that Docker opens ports automatically: Traffic that targets a port
> mapped by Docker, where the traffic originates somewhere on the same machine the container runs on,
> and not from a machine somewhere else, will not be automatically handled by the Docker firewall rules, 
> and will require an explicit ufw rule. For example, if the intent is to have multiple eth2 beacons 
> reference one eth1 node: `sudo ufw allow from 172.16.0.0/12 to any port 8545` and `sudo ufw deny 8545`. 
> The assumption here is that port `8545` is used for the connection to eth1, and that the eth2 beacons
> are themselves inside docker containers. With this rule, traffic from other containers to eth1
> would succeed, and traffic from "the Internet" to eth1 would not, as long as [cloud security](CLOUD.md)
> steps have also been taken.
## Time synchronization on Linux

The blockchain requires precise time-keeping. You can use systemd-timesyncd if your system offers it,
or [ntpd](https://en.wikipedia.org/wiki/Network_Time_Protocol) to synchronize time on your Linux server.
systemd-timesyncd uses a single ntp server as source, and ntpd uses several, typically a pool.
My recommendation is to use ntpd for better redundancy.

For Ubuntu, first switch off the built-in, less redundant synchronization and verify it is off. 
You should see `NTP service: inactive`.

```
sudo timedatectl set-ntp no
timedatectl
```

Then install the ntp package. It will start automatically.<br />
`sudo apt update && sudo apt install ntp`

Check that ntp is running correctly: Run `ntpq -p` , you expect to see a number of ntp time servers with
IP addresses in their `refid`, and several servers with a refid of `.POOL.`

> If you wish to stay with systemd-timesyncd instead, check that `NTP service: active` via 
> `timedatectl`, and switch it on with `sudo timedatectl set-ntp yes` if it isn't. You can check
> time sync with `timedatectl timesync-status --all`.

## SSH key authentication with Linux

For security reasons, you want some form of two-factor authentication for SSH login, particularly if SSH
is exposed to the Internet. These instructions accomplish that by creating an SSH key with passphrase.
Alternatively or in addition, you could set up [two-factor authentication with one-time passwords](https://www.coincashew.com/coins/overview-eth/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node#setup-two-factor-authentication-for-ssh-optional).

To switch to SSH key authentication instead of password authentication, you will start
on the machine you are logging in from, whether that is Windows 10, MacOS or Linux, and then
make changes to the server you are logging in to.

On Windows 10, you expect the [OpenSSH client](https://winaero.com/blog/enable-openssh-client-windows-10/)
to already be installed. If it isn't, follow that link and install it.

From your MacOS/Linux Terminal or Windows Powershell, check whether you have an ssh key. You expect an id_TYPE.pub
file when running `ls ~/.ssh`.

### Create an SSH key pair

Create a key if you need to, or if you don't have `id_ed25519.pub` but prefer that cipher:<br />
`ssh-keygen -t ed25519`. Set a strong passphrase for the key.
> Bonus: On Linux, you can also include a timestamp with your key, like so:<br />
> `ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)-$(date -I)" -f ~/.ssh/id_ed25519`

### MacOS/Linux, copy public key

 If you are on MacOS or Linux, you can then copy this new public key to the Linux server:<br />
`ssh-copy-id USERNAME@HOST`

### Windows 10, copy public key

On Windows 10, or if that command is not available, output the contents of your public key file
to terminal and copy, here for `id_ed25519.pub`:<br />
`cat ~/.ssh/id_ed25519.pub`

On your Linux server, logged in as your non-root user, add this public key to your account:<br />
```
mkdir ~/.ssh
nano ~/.ssh/authorized_keys
```
And paste in the public key.

### Test login and turn off password authentication

Test your login. `ssh user@serverIP` from your client's MacOS/Linux Terminal or Windows Powershell should log you in
directly, prompting for your key passphrase, but not the user password.

If you are still prompted for a password, resolve that first. Your ssh client should show you errors in that case. You
can run `ssh -v user@serverIP` to get more detailed output on what went wrong.

On Windows 10 in particular, if the ssh client complains about the "wrong permissions" on the `.ssh` directory or
`.ssh/config` file, go into Explorer, find the `C:\Users\USERNAME\.ssh` directory, edit its Properties->Security, click
Advanced, then make your user the owner with Full Access, while removing access rights to anyone else, such as SYSTEM
and Administrators. Check "Replace all child object permissions", and click OK. That should solve the issues the
OpenSSH client had.

Lastly, once key authentication has been tested, turn off password authentication. On your Linux server:<br />
`sudo nano /etc/ssh/sshd_config`

Find the line that reads `#PasswordAuthentication yes` and remove the comment character `#` and change it to `PasswordAuthentication no`.

And restart the ssh service, for Ubuntu you'd run `sudo systemctl restart ssh`.

## Set Linux to auto-update

Since this system will be running 24/7 for the better part of 2 years, it's a good idea to have it patch itself.
Enable [automatic updates](https://libre-software.net/ubuntu-automatic-updates/) and install software so the
server can [email you](https://www.havetheknowhow.com/Configure-the-server/Install-ssmtp.html).

For automatic updates, `"only-on-error"` mail reports make sense once you know email reporting is working and
if you choose automatic reboots, trusting that your services will all come back up on reboot. If you'd like
to keep a closer eye or schedule reboots yourself, `"on-change"` MailReport is a better choice.

For ssmtp, I followed the instructions as-is with one change: I do not see the sense of changing the `hostname`
to my email address, and so didn't.

## Set up IPMI

This step is highly hardware-dependent. If you went with a server that has IPMI/BMC - out of band management of
the hardware - then you'll want to configure IPMI to email you on error.
## Continue with README file

You are now ready to build and run your eth2 client.
