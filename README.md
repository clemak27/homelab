# my homelab setup

This repo the setup for my homelab.

It currently consists of single bare-metal server running Fedora CoreOS, with
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

### Fedora CoreOS

My homelab runs [FCOS](https://docs.fedoraproject.org/en-US/fedora-coreos/).

[WireGuard](https://www.wireguard.com/) is running directly on the host, for
accessing my homelab from the outside.

[blocky](https://0xerr0r.github.io/blocky/latest/) and a nfs-server run as
quadlets.

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
