Docker container for go-ethereum geth
Configured for goerli testnet, see CMD and override as desired

Use Dockerfile.sourcebuild to compile from source

This creates a statically compiled geth, in a scratch container, for minimal attack surface

Pass BUILD_TARGET, USER and UID during build if you are not using docker-compose

Firewalling: You want 30303/tcp and 30303/udp to be exposed to "the Internet", port-forwarded if
this runs behind NAT. Do NOT expose 8545/tcp to world, it is http and meant only for other containers
to interface with.

The following assumes Ubuntu, hence sudo to run docker. If that's not necessary in your environment,
just leave sudo off the command and run directly as the logged-in user.

You'd run this from the docker-compose one level up. To test build and run here, while mapping to default ports:

sudo docker build -t geth --build-arg BUILD_TARGET=release/1.9 --build-arg USER=geth --build-arg UID=10001 .
sudo docker volume create geth-goerli
sudo docker run -d --name geth -v geth-goerli:/var/lib/goethereum -p 30303:30303 -p 30303:30303/udp -p 8545:8545 geth

Example of running on port 30305 to world and 8555 for the RPC-JSON endpoint:

sudo docker run -d --name geth -v geth-goerli:/var/lib/goethereum -p 30305:30303 -p 30305:30303/udp -p 8555:8545 geth

Watch logs:

sudo docker logs -f geth

Prune build images - saves space if no further builds are likely:

sudo docker system prune -f
