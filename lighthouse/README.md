Docker container for lighthouse eth2 client
Configured for medalla testnet, see CMD and override as desired

This creates a statically compiled lighthouse, in a scratch container, for minimal attack surface

Pass --build-arg options BUILD_TARGET, USER and UID during build if you are not using docker-compose

Firewalling: You want 9000/tcp and 9000/udp to be exposed to "the Internet", port-forwarded if
this runs behind NAT. Do NOT expose 5052/tcp to world, it is http and meant only for other containers
to interface with.

The following assumes Ubuntu, hence sudo to run docker. If that's not necessary in your environment,
just leave sudo off the command and run directly as the logged-in user.

You'd run this from the docker-compose one level up. To test build and run here, while mapping to default ports
and connecting to medalla testnet and an eth1 node in a container called "geth":

```
sudo docker build -t lighthouse --build-arg BUILD_TARGET=master --build-arg USER=lighthouse --build-arg UID=10002 .
sudo docker volume create lighthouse-beacon
sudo docker run -d --name lighthouse-beacon -v lighthouse-beacon:/var/lib/lighthouse -p 9000:9000 -p 9000:9000/udp -p 5052:5052 lighthouse 
```
Example of running on port 9010 to world and 5152 for the RPC-JSON endpoint:

```
sudo docker run -d --name lighthouse-beacon -v lighthouse-beacon:/var/lib/lighthouse -p 9010:9000 -p 9010:9000/udp -p 5152:5052 lighthouse
```

Watch logs:

```
sudo docker logs -f lighthouse
```
Prune build images - saves space if no further builds are likely:

```
sudo docker system prune -f
```
