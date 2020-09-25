# Prerequisites


This project relies on docker and docker-compose, and git to bring the
project itself in. It has been tested on Linux and Windows 10, and is
expected to work on MacOS.

## Ubuntu Prerequisites

```
sudo apt update && sudo apt dist-upgrade
sudo apt install docker docker-compose git
```

Other distributions are expected to work as long as they support
git, docker, and docker-compose.

On Linux, docker-compose runs as root by default. The individual containers do not,
they run as local users inside the containers. "Rootless mode" is expected to
work for docker with this project, as it does not (yet) use AppArmor.

## Windows 10 Prerequisites

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/win), and [Python 3](https://www.python.org/downloads/windows/). Note you can also type `python3` into a Powershell window and it will bring you to the Microsoft Store for a recent Python 3 version.

Docker Desktop can be used with the WSL2 backend if desired, or without it.

You will run the docker-compose and docker commands from Powershell. You do not need `sudo` in front of those commands.

## MacOS Prerequisites

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/mac) and [Python 3](https://www.python.org/downloads/mac-osx/).
MacOS has not been tested, if you have the ability to, please get in touch via the ethstaker Discord.

