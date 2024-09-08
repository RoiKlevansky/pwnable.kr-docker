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
> docker-compose up -d
```

### Connect to the container

```bash
> docker exec -it pwnable-kr-docker [zsh|bash]
```

Default crednitals are: ```ubuntu:1```.

## gdbserver

If you'd want to connect to the server from your host machine use port 
```2159``` which is exposed to your host.
