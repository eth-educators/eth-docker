# Prerequisites


This project relies on docker and docker-compose, and git to bring the
project itself in. It has been tested on Linux, and is
expected to work on MacOS.

## Ubuntu Prerequisites

> Note: The following prerequisites will be installed on the Linux server you
> will run your node on. The machine you use to connect *to* the Linux server
> only requires an SSH client.

Update all packages
```
sudo apt update && sudo apt dist-upgrade
```
and install prerequisites
```
sudo apt install -y docker docker-compose git
```
then enable the docker service
```
sudo systemctl enable --now docker
```

> After installation, the docker service might not be enabled to start on
> boot. The systemctl command above enables it.
> Verify the status of the docker service with `sudo systemctl status docker`

You know it was successful when you saw messages scrolling past that install git,
docker and docker-compose.

Other distributions are expected to work as long as they support
git, docker, and docker-compose.

On Linux, docker-compose runs as root by default. The individual containers do not,
they run as local users inside the containers. "Rootless mode" is expected to
work for docker with this project, as it does not (yet) use AppArmor.

## MacOS Prerequisites

> The following prerequisites apply if you are going to use MacOS as a server
> to run an eth2 node. If you use MacOS to connect *to* a node server, all
> you need is an SSH client.

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/mac) and [Python 3](https://www.python.org/downloads/mac-osx/).
MacOS has not been tested, if you have the ability to, please get in touch via the ethstaker Discord.

## Windows 10 discouraged

While it is technically possible to run this project, and thus a node, on Windows 10,
I want to [discourage that idea](WINDOWS.md). Windows 10 is fine as an SSH client to connect *to*
your Linux server, but not as a basis to run the node server itself inside Docker.

The challenges inherent in running on Windows 10 are easier to solve when using the Windows-native
versions of the clients, rather than wrapping Docker around them.
