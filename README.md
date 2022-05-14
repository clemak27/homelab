# my homelab setup

This repo contains my dotfiles + setup for my homelab.

## Hardware

My "homelab" is currently a server + a Raspberry Pi 3B.
No fancy routes, switches or vlan.
The server is also a repurposed laptop,
so there's not even a fancy rack to show off :(

## Software

Both devices are running NixOS. Almost everything I have is running in docker-containers,
so Nix just takes the definitions I wrote and does some `docker run` commands.
The repo is running renovate, which automatically checks for
new versions of docker images.
There is also a script running, that watches the git repo for
changes and deploys them if there are any.
