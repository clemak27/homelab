# my homelab setup

This repo the setup for my homelab.

It currently consists of a server running NixOS, with k3s to deploy containers.

## Structure

- `cluster`
  definition of all services running in the cluster
- `hosts`
  configuration files for server and virtual machine
- `modules`
  general configuration files used by all hosts
- `setup`
  notes for setting up my homelab

## Hardware

HDDs
nfs

## Software

### NixOS

My homelab runs [NixOS](https://nixos.org/). The host's `configuration.nix`
sets the base and machine-specific settings and imports from `modules` as needed.

The update-process works via gitops, so the state of the servers
is always equal to the definition in this repo.
To achieve this, the `gitops.nix` module creates a systemd-service that runs regularly.
This service updates the repo (that is checked out on the host),
and checks if any nix-config files changed. If yes, the new configuration is applied.
Should the `flake.lock` have changed, a reboot is scheduled.

There 2 other services directly running on the host and configured with nix:
[WireGuard](https://www.wireguard.com/), for accessing my homelab from the outside,
and [dnsmasq](https://dnsmasq.org/), for resolving hostnames and some ad-blocking.

### k3s

Most other services run in a Kubernetes cluster. To deploy it I use [k3s](https://k3s.io/).
The cluster is managed with [argoCD](https://argoproj.github.io/cd),
which watches the cluster directory for changes and automatically
applies them to the cluster.

Storage and backups are managed with [longhorn](https://github.com/longhorn/longhorn).
Secrets are handled using [helm-secrets](https://github.com/jkroepke/helm-secrets).

### other

[Sops](https://github.com/mozilla/sops) is used for secrets,
both with helm-secrets and [nix-sops](https://github.com/Mic92/sops-nix)

[Renovate](https://github.com/renovatebot/renovate) automatically
creates pull requests for updating dependencies.

There are also a few configs for linting and
corresponding github-actions that lint new pull requests.
