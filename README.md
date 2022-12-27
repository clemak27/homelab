# my homelab setup

This repo the setup for my homelab.

It currently consists of a server running Fedora CoreOS.

It runs [k3s](https://github.com/k3s-io/k3s) and uses
[argo](https://github.com/argoproj/argo-cd) for gitops. Certificates are issued
with [cert-manager](https://github.com/cert-manager/cert-manager)
and for managing storage, [longhorn](https://github.com/longhorn/longhorn) is used.
Secrets are handled using [helm-secrets](https://github.com/jkroepke/helm-secrets)
with [sops](https://github.com/mozilla/sops) as backend.
[Renovate](https://github.com/renovatebot/renovate) automatically
creates PRs for updating dependencies.

Access to it is restricted to my network, but I use wireguard to access it remotely.
To access my services by domains, I run a dnsmasq server on it as well.

I'm also planning to re-integrate a RockPro64 I have into
my setup and installing CoreOS on it as well.

## Structure

- `cluster`
  definition of all services running in the cluster
- `hosts`
  ignition files for server and virtual machine
- `modules`
  ignition files for server functionality
- `Makefile`
