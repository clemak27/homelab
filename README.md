# my homelab setup

This repo the setup for my homelab.

It currently consists of single bare-metal server running Fedora IoT, with k3s
to deploy containers.

This is for my own usage and preferences, but you are of course free to use it
as inspiration.

## Structure

- `cluster`
  - definition of all services running in the cluster
- `host`
  - configuration files for server
- `setup`
  - notes for setting up my homelab

## Hardware

- AMD Ryzen 5 5600G
- ASRock A520M-ITX/ac
- 16GB
- a few TB disc space

## Software

### Fedora IoT

My homelab runs [Fedora IoT](https://fedoraproject.org/iot/). Despite the name,
it is not just useable on IoT devices but also normal PCs. It is basically
Fedora Server with the atomic updates of Silverblue/Kinoite.

There 2 services directly running and configured on the host:
[WireGuard](https://www.wireguard.com/), for accessing my homelab from the
outside, and [dnsmasq](https://dnsmasq.org/), for resolving hostnames.

For configuring, I just use plain Makefiles and no Ansible or terraform Maybe I
will use ignition in the future, since technically Fedora IoT also supports it,
but for now I'm fine.

### k3s

Most other services run in a Kubernetes cluster. To deploy it I use
[k3s](https://k3s.io/). The cluster is managed with
[argoCD](https://argoproj.github.io/cd), which watches the cluster directory for
changes and automatically applies them to the cluster.

Storage and backups are managed with
[longhorn](https://github.com/longhorn/longhorn). Secrets are handled using
[ksops](https://github.com/viaduct-ai/kustomize-sops).

### other

[Renovate](https://github.com/renovatebot/renovate) automatically creates pull
requests for updating dependencies.

There are also a few configs for linting and corresponding github-actions that
lint new pull requests.
