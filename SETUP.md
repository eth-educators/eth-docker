# Initial setup

If you haven't already, please see [prerequisites](PREREQUISITES.md) and meet them for your OS.
This file steps you through client choice as well as some basic host security steps on Linux.

## Non-root user on Linux

If you are logged in as root, create a non-root user with your `USERNAME` of choice to log in as,
and give it sudo rights. `sudo` allows you to run commands `as root` while logged in as a non-root
user. This may be needed on a VPS, and is not typically needed on a local fresh install of Ubuntu.

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
  * Nimbus - as of 10/09 requires an archive-mode geth or remote archive like goerli.infura.io
* Your source of eth1 data
  * geth
  * 3rd-party
* Whether to run a slasher (not yet implemented)
* Whether to run a grafana dashboard for monitoring

> Note: Teku is written in Java, which makes it memory-hungry. In its default configuration, you may
> want a machine with 16 GiB of RAM. See `.env` for a parameter to restrict Teku to 6 GiB of heap. It
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
and with which options. See below for available compose files
- If you are going to use a 3rd-party provider as your eth1 chain source, set `ETH1_NODE` to that URL.
  See [how to create your own Infura account](https://status-im.github.io/nimbus-eth2/infura-guide)
- Adjust ports if you are going to need custom ports instead of the defaults. These are the ports
exposed to the host, and for everything but Grafana to the Internet via your firewall/router
- Set the `NETWORK` variable to either "mainnet" or a test network such as "medalla"
- Comment out the `ETH_NETWORK` variable, to use the main net, or set it to a test network such as "--goerli",
  with the two dashes.
- Set the `GRAFFITI` string if you want a specific string

### Client compose files

Set the `COMPOSE_FILE` string depending on which client you are going to use. Add optional services like
geth with `:` between the file names.
- `lh-base.yml` - Lighthouse
- `prysm-base.yml` - Prysm
- `teku-base.yml` - Teku
- `nimbus-base.yml` - Nimbus
- `geth.yml` - local geth eth1 chain node
- `lh-grafana.yml` - grafana dashboard for Lighthouse
- `prysm-grafana.yml` - grafana dashboard for Prysm. Not encrypted, do not expose to Internet.
- `prysm-web.yml` - Prysm experimental Web UI. Not encrypted, do not expose to Internet.
- `prysm-slasher.yml` - Prysm experimental Web UI. Not encrypted, do not expose to Internet.
- `nimbus-grafana.yml` - grafana dashboard for Nimbus
- `teku-grafana.yml` - grafana dashboard for Teku

For example, Lighthouse with local geth and grafana:
`COMPOSE_FILE=lh-base.yml:geth.yml:lh-grafana.yml`

> See [WEB](WEB.md) for notes on using the experimental Prysm Web UI

In this setup, clients are isolated from each other. Each run their own validator, and if geth
is in use, their own geth. This is perfect for running a single client, or multiple isolated
clients each in their own directory.

If you want to run multiple isolated clients, just clone this project into a new directory for
each. This is great for running medalla and zinken in parallel, for example.

### `SLASHER`   
Running [slasher](https://docs.prylabs.network/docs/prysm-usage/slasher/) is an optional client compose file, but helps secure the chain and may result in additional earnings.
```
Slasher can be a huge resource hog during times of no chain finality, which can manifest as massive RAM usage. Please make sure you understand the risks of this, especially if you want high uptime for your beacon nodes. Slasher places significant stress on beacon nodes when the chain has no finality, and might be the reason why your validators are underperforming if your beacon node is under this much stress.
```

## Firewalling

You'll want to forward ports to the services of your eth2 node, and on Linux, enable a host firewall.
These are the relevant ports. docker will open eth2 node ports and the grafana port automatically,
please make sure the grafana port cannot be reached directly. If you need to get to grafana remotely,
an SSH tunnel is a good choice.
Ports that I mention should be "Open to Internet" need to be either forwarded
to your node if behind a home router, or allowed in via the VPS firewall.

- 30303 tcp/udp - local eth1 node, geth or openethereum. Open to Internet.
- 9000 tcp/udp - Lighthouse beacon node. Open to Internet.
- 13000/tcp - Prysm beacon node. Open to Internet.
- 12000/udp - Prysm beacon node. Open to Internet.
- 9000 tcp/udp - Teku beacon node. Open to Internet. Note this is the same as Lighthouse.
- 9000 tcp/udp - Nimbus beacon node. Open to Internet. Note this is the same as Lighthouse.
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

If you wish to stay with systemd-timesyncd, check that `NTP service: active` via 
`timedatectl`, and switch it on with `sudo timedatectl set-ntp yes` if it isn't. You can check
time sync with `timedatectl timesync-status --all`.

## SSH key authentication with Linux

This is for logging into your node server, assuming that node server runs Linux. You will start
on the machine you are logging in from, whether that is Windows 10, MacOS or Linux, and then
make changes to the server you are logging in to.

On Windows 10, you expect the [OpenSSH client](https://winaero.com/blog/enable-openssh-client-windows-10/)
to already be installed. If it isn't, follow that link and install it.

From your MacOS/Linux Terminal or Windows Powershell, check whether you have an ssh key. You expect an id_TYPE.pub
file when running `ls ~/.ssh`.

### Create an SSH key pair

Create a key if you need to, or if you don't have `id_ed25519.pub` but prefer that cipher:<br />
`ssh-keygen -t ed25519`
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
directly without prompting for a password.

If you are still prompted for a password, resolve that first. Your ssh client should show you errors in that case.
On Windows 10 in particular, if the ssh client complains about the "wrong permissions" on the `.ssh` directory or
`.ssh/config` file, go into Explorer, find the `C:\Users\USERNAME\.ssh` directory, edit its Properties->Security, click
Advanced, then make your user the owner with Full Access, while removing access rights to anyone else, such as SYSTEM
and Administrators. That should solve the issues the OpenSSH client had.

Lastly, once key authentication has been tested, turn off password authentication. On your Linux server:<br />
`sudo nano /etc/ssh/sshd_config`

Find the line that reads `#PasswordAuthentication yes` and remove the comment character `#` and change it to `PasswordAuthentication no`.

And restart the ssh service, for Ubuntu you'd run `sudo systemctl restart ssh`.

## Continue with README file

You are now ready to build and run your eth2 client.
