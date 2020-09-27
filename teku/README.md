Docker container for Teku eth2 client

This creates a compiled Teku, in a debian-slim container

Pass BUILD_TARGET, USER and UID during build if you are not using docker-compose

Firewalling: You want 9000 tcp/udp to be exposed to "the Internet", port-forwarded if
this runs behind NAT.<br />
Note this is the same default port that Lighthouse uses. Adjust the port on your host
through `.env` if you are testing both clients.

The following assumes Ubuntu, hence sudo to run docker. If that's not necessary in your environment,
just leave sudo off the command and run directly as the logged-in user.

You'd run this from the docker-compose one level up. To test build and run here, while mapping to default ports:

sudo docker build -t teku --build-arg BUILD_TARGET=master --build-arg USER=teku --build-arg UID=$UID .
sudo docker volume create teku-data
sudo docker run -d --name teku -v teku:/var/lib/teku -p 9000:9000 -p 9000:9000/udp teku

Example of running on port 9010 to world:

sudo docker run -d --name teku -v teku:/var/lib/teku -p 9010:9000 -p 9010:9000/udp teku

Watch logs:

sudo docker logs -f teku

Prune build images - saves space if no further builds are likely:

sudo docker system prune -f
