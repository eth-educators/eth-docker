Docker container for Prysmatic prysm
Configured for medalla testnet, see CMD and override as desired

This creates a statically compiled prysm, in a scratch container, for minimal attack surface

Pass BUILD_TARGET, USER and UID during build if you are not using docker-compose

Firewalling: You want 13000/tcp and 12000/udp to be exposed to "the Internet", port-forwarded if
this runs behind NAT. Do NOT expose 8545/tcp to world, it is http and meant only for other containers
to interface with.

The following assumes Ubuntu, hence sudo to run docker. If that's not necessary in your environment,
just leave sudo off the command and run directly as the logged-in user.

You'd run this from the docker-compose one level up. To test build and run here, while mapping to default ports:

sudo docker build -t prysm --build-arg BUILD_TARGET=master --build-arg USER=prysm --build-arg UID=10001 .
sudo docker volume create prysm-data
sudo docker run -d --name prysm -v prysm-data:/var/lib/prysm -p 13000:13000 -p 12000:12000/upd -p 8545:8545 prysm

Example of running on ports 13010 and 12010 to world and 8555 for the RPC-JSON endpoint:

sudo docker run -d --name prysm -v prysm-data:/var/lib/prysm -p 13010:13000 -p 12010:12000/upd -p 8555:8545 prysm

Watch logs:

sudo docker logs -f prysm

Prune build images - saves space if no further builds are likely:

sudo docker system prune -f
