# my homelab setup

This repo contains my dotfiles + setup for my homelab.

## Hardware

My "homelab" is currently a single server. No fancy routes, switches or vlan.
It's also a repurposed laptop, so there's not even a fancy rack to show off :(
If I add additional devices to my lab, I might consider improving it hardware wise as well.

## Software

My server is running NixOS. Almost everything I have is runing in docker-containers,
so Nix just takes the definitions I wrote and does some `docker run` commands.
The repo is running renovate, which automatically checks for new versions of docker images.
There is also a script running, that watches the git repo for changes and deploys them if there are any.

## Other

I once cleaned up the git history to use conventional commits throughout, so don't wonder
why there are so many commits made in one day.
