Docker container for Nimbus eth2 client

This creates a compiled nimbus, in a debian-slim container

Pass BUILD_TARGET, USER and UID during build if you are not using docker-compose, as well as METRICS
which is the compile-time flag for the http metrics server

Firewalling: You want 19000 tcp/udp to be exposed to "the Internet", port-forwarded if
this runs behind NAT. Do NOT expose 8008/tcp to world, it is http and meant only for the dashboard
to interface with to get metrics

A few notes on compilation and runtime options

The git branch to build should be `devel` as of Sept 2020
The validator is included with the beacon node by default. They can be separated, but the code is still experimental.
Max peers default is 79, you will not likely have to adjust this.
Metrics require `NIMFLAGS="-d:insecure"` during compile. This option is exposed to the user via .env so they can
decide on whether to include metrics.

This Dockerfile compiles for the machine it is being executed on, the resulting executable is **not** portable to
other architectures. `make NIMFLAGS="-d:disableMarchNative" beacon_node` is the way to build portable binaries,
but that is outside the purview of this project. See https://github.com/status-im/nim-beacon-chain/tree/devel#makefile-tips-and-tricks-for-developers

A static binary can be compiled with `make NIMFLAGS="--passL:-static" beacon_node`, but running in scratch was
not successful, therefore I am not doing a static compile.

The following assumes Ubuntu, hence sudo to run docker. If that's not necessary in your environment,
just leave sudo off the command and run directly as the logged-in user.

You'd run this from the docker-compose one level up. To test build and run here, while mapping to default ports:

sudo docker build -t nimbus --build-arg BUILD_TARGET=devel --build-arg USER=nimbus --build-arg UID=$UID .
sudo docker volume create nimbus-data
sudo docker run -d --name nimbus -v nimbus:/var/lib/nimbus -p 19000:19000 -p 19000:19000/udp nimbus

Example of running on port 19010 to world:

sudo docker run -d --name nimbus -v nimbus:/var/lib/nimbus -p 19010:19000 -p 19010:19000/udp nimbus

Watch logs:

sudo docker logs -f nimbus

Prune build images - saves space if no further builds are likely:

sudo docker system prune -f
