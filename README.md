# Pwnable.kr-docker

A local replica of the pwnable.kr server.

NOTICE: The docker image doesn't include any of the pwnable.kr challenges, you'll have to download them yourself. This image is meant to be used for exploit development and debugging.

## Installed tools

* The important apt packages from the original server (like libc, etc...)
* Python3.12
* Pwntools (https://github.com/Gallopsled/pwntools)
* pwndbg (https://github.com/pwndbg/pwndbg)
* gdbserver
* tmux and gnome-terminal, for easy pwntools debugging
* Many more...

## Getting Started

### Dependencies:

- Docker

### Clone this project

```bash
> git clone https://github.com/RoiKlevansky/pwnable.kr-docker
> cd pwnable.kr-docker
```

### Build the image and run the container

```bash
> docker compose up -d
```

### Connect to the container

Default credentials are: ```ubuntu:1```.

#### Using SSH

The recommended way to connect to the container is using SSH. This will also allow you to use X11 forwarding:

```bash
> ssh -X ubuntu@172.16.128.2
```

The container is fixed to use this address.

#### Using docker exec

NOTE: You will NOT be able to open X11 applications this way.

```bash
> docker exec -it pwnable-kr-docker [zsh|bash]
```

## gdbserver

If you'd want to connect to the server from your host machine use port 
```2159``` which is exposed to your host.
