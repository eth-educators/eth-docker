# Prerequisites

This project relies on docker and docker-compose, and git to bring the project
files themnselves in.

## Ubuntu Prerequisites

To run the client with defaults, assuming an Ubuntu host:

```
sudo apt update && sudo apt install docker docker-compose git
cd
git clone https://github.com/eth2-educators/eth2-docker.git
cd eth2-docker
cp default.env .env
```

You **must** adjust the contents of `.env` to your environment. Specifically,
`LOCAL_UID` needs to be set to your UID, which you can get with `echo $UID`.
The default is `1000`, which hopefully covers the majority of cases.<br />
This step became necessary because of an upcoming security change to how
eth2.0-deposit-cli sets permissions on the files it creates.

Other distributions are expected to work as long as they support
git, docker, and docker-compose.

## Windows 10 Prerequisites

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/win), and [Python 3](https://www.python.org/downloads/windows/). Note you can also type `python3` into a Powershell window and it will bring you to the Microsoft Store for a recent Python 3 version.

You have to copy the `default.env` file to `.env`, from Powershell: `cp default.env .env`.
After copying this file, you may want to adjust the contents of `.env` to your environment.

Docker Desktop can be used with the WSL2 backend if desired, or without it.

You will run the docker-compose and docker commands from Powershell. You do not need `sudo` in front of those commands.

## MacOS Prerequisites

Install [Docker Desktop](https://www.docker.com/products/docker-desktop), [git](https://git-scm.com/download/mac) and [Python 3](https://www.python.org/downloads/mac-osx/).
MacOS has not been tested, if you have the ability to, please get in touch via the ethstaker Discord.

