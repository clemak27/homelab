# my homelab setup

This repo the setup for my homelab.

It currently consists of single bare-metal server running NixOS, with
k3s to deploy containers.

This is for my own usage and preferences, but you are of course free to use it
as inspiration.

## Structure

- `flux`
  - definition of all services running in the cluster
- `hosts`
  - configuration files for server
- `modules`
  - configuration files for different modules

## Hardware

- AMD Ryzen 5 5600G
- ASRock A520M-ITX/ac
- 16GB
- a few TB disc space

## Software

### NixOS

My homelab runs [NixOS](https://nixos.org/).

[WireGuard](https://www.wireguard.com/),
[blocky](https://0xerr0r.github.io/blocky/latest/) and an nfs-server are running
directly on the host.

### k3s

All other services run in a Kubernetes cluster. To deploy it I use
[k3s](https://k3s.io/). The cluster is managed with
[fluxCD](https://fluxcd.io/), which watches the repo for changes and
automatically applies them to the cluster.

Storage and backups for container-volumes are managed with
[longhorn](https://github.com/longhorn/longhorn).

### other

[Renovate](https://github.com/renovatebot/renovate) automatically creates pull
requests for updating dependencies.

There are also a few configs for linting and corresponding github-actions that
lint new pull requests.
