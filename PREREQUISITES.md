# Prerequisites


This project relies on docker and docker-compose, and git to bring the
project itself in. It has been tested on Linux, and is
expected to work on MacOS.

## Ubuntu Prerequisites

> Note: The following prerequisites will be installed on the Linux server you
> will run your node on. The machine you use to connect *to* the Linux server
> only requires an SSH client.

```
sudo apt update && sudo apt dist-upgrade
sudo apt install docker docker-compose git
```

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
I want to discourage that idea. Windows 10 is fine as an SSH client to connect *to*
your Linux server, but not as a basis for the node server itself.

In testing, Windows 10 time synchronization was less than accurate, and WSL2 would lose
time sync when a machine goes to sleep and comes back out. In addition, WSL2 has no systemd
and so cannot run Linux-native time sync easily.

While this can all be solved with the use of 3rd-party software, I don't want to be
responsible for someone losing money because time was off.

If you know enough to get Windows 10 and WSL2 time sync stable, you likely also know enough
to run a Linux server in the first place.
