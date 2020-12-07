# Running eth2-docker in the cloud

For the most part, nothing special needs to be done to run eth2-docker on a VPS. However, budget VPS providers do not
filter the traffic that can reach the machine: This is definitely not desirable for unsecured ports like Grafana
or eth1, if the shared/standalone option is being used. All that should be reachable are the P2P ports.

## Securing Grafana and eth1 via ufw

While Docker automatically opens the Linux firewall for ports it "maps" to the host, it also
allows rules to be placed in front of that, via the `DOCKER-USER` chain.

The following idea uses that chain and integrates ufw with it, so that simple ufw rules can
be used to secure Grafana.

### 1) Edit after.rules:

`sudo nano /etc/ufw/after.rules` and add to the end of the file, *after* the existing `COMMIT`:

```
*filter
:ufw-user-input - [0:0]
:DOCKER-USER - [0:0]

# ufw in front of docker while allowing all inter-container traffic

-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16

-A DOCKER-USER -j ufw-user-input
-A DOCKER-USER -j RETURN

COMMIT
```

Note this deliberately keeps ufw rules from influencing any traffic sourced from RFC1918 (private) addresses, which includes the
docker containers.  This may *not* be what you need, in which case just remove those three lines, and be sure to allow needed
container traffic through explicit ufw rules, if you are blocking a port.

### 2) Edit before.init

`sudo nano /etc/ufw/before.init` and change `stop)` to read:

```
stop)
    # typically required
    iptables -F DOCKER-USER || true
    iptables -A DOCKER-USER -j RETURN || true
    iptables -X ufw-user-input || true
```

Then, make it executable: `sudo chmod 750 /etc/ufw/before.init`

Dropping `ufw-user-input` through `before.init` is a required step. Without it, ufw cannot be reloaded, it would display an error message
stating "ERROR: Could not load logging rules".

### 3) Reload ufw

`sudo ufw reload`

### Example: Grafana on port 3000

Reference [common ufw rules and commands](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
to help in creating ufw rules.

Say I have Grafana enabled on port 3000 and no reverse proxy. I'd like to keep it reachable via [SSH tunnel](https://www.howtogeek.com/168145/how-to-use-ssh-tunneling/)
while dropping all other connections.

First, verify that Grafana is running and port 3000 is open to world using something like https://www.yougetsignal.com/tools/open-ports/

Next, create ufw rules to allow access from `localhost` and drop access from anywhere else:

- `sudo ufw allow from 127.0.0.1 to any port 3000` 
- `sudo ufw deny 3000` 

Check again on "yougetsignal" or the like that port 3000 is now closed.

Connect to your node with ssh tunneling, e.g. `ssh -L3000:node-IP:3000 user@node-IP` and browse to `http://127.0.0.1:3000` on the client
you started the SSH session *from*. You expect to be able to reach the Grafana dashboard.

### Example: Shared or standalone eth1 on port 8545

It can be useful to have a single eth1 node service multiple beacons, for example when testing, or running a solo
staking docker-compose stack as well as a pool docker-compose stack.

To allow Docker traffic to eth1 while dropping all other traffic:
- `sudo ufw allow from 172.16.0.0/12 to any port 8545`
- `sudo ufw deny 8545`

> With ISP traffic caps, it could be quite attractive to run eth1 in a small VPS, and reference it from a beacon somewhere
> else. This would require an eth1 proxy and TLS encryption, and likely client authentication. If that is your use case,
> a PR would be welcome, if you can get to it before I do.

## Acknowledgements

The ufw integration is a slightly tweaked version of https://github.com/chaifeng/ufw-docker by way 
of https://p1ngouin.com/posts/how-to-manage-iptables-rules-with-ufw-and-docker