# my homelab setup

This repo the setup for my homelab.

It currently consists of a small cluster running NixOS, with k3s to deploy
containers.

## Structure

- `cluster`
  - definition of all services running in the cluster
- `hosts`
  - configuration files for servers
- `modules`
  - general configuration files used by all hosts
- `setup`
  - notes for setting up my homelab

## Hardware

| hostname | hardware               |
| -------- | ---------------------- |
| theia    | Pine64 RockPro64       |
| phobos   | Raspberry Pi 4 Model B |
| deimos   | Raspberry Pi 4 Model B |

## Software

### NixOS

My homelab runs [NixOS](https://nixos.org/). The host's `configuration.nix` sets
the base and machine-specific settings and imports from `modules` as needed.

There 2 services directly running and configured with nix:
[WireGuard](https://www.wireguard.com/), for accessing my homelab from the
outside, and [dnsmasq](https://dnsmasq.org/), for resolving hostnames.

### k3s

Most other services run in a Kubernetes cluster. To deploy it I use
[k3s](https://k3s.io/). The cluster is managed with
[argoCD](https://argoproj.github.io/cd), which watches the cluster directory for
changes and automatically applies them to the cluster.

Storage and backups are managed with
[longhorn](https://github.com/longhorn/longhorn). Secrets are handled using
[ksops](https://github.com/viaduct-ai/kustomize-sops).

### other

[Sops](https://github.com/mozilla/sops) is used for secrets, both with ksops and
[nix-sops](https://github.com/Mic92/sops-nix)

[Renovate](https://github.com/renovatebot/renovate) automatically creates pull
requests for updating dependencies.

There are also a few configs for linting and corresponding github-actions that
lint new pull requests.
