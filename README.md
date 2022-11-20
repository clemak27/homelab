# my homelab setup

This repo the setup for my homelab.

The current iteration is a Server running Fedora CoreOS, it used to be an old
thinkpad + raspberyyPI in the Past.

## Structure

- `hosts`
  The definitions for each host and which modules they require.
- `modules`
  Several butane files for different functionalities.
- `services`
  This directory contains all services running on my server and is orchestrated
  via `docker-compose`
- `Makefile`
  A Makefile containing several targets that help running the server

## Usage

Most things can be done by using the provided `Makefile`.
Since I use Fedora Silverblue, it assumes it is run from a toolbox.

### k3d

The k3s cluster can also be deployed locally using k3d.
Since I use Fedora Silverblue, it requires some additional steps:

- overlay `podman-docker`
- enable the podman socket:
  - `sudo systemctl enable --now podman.socket`
- make sure the docker socket is pointed at the right file:
  - /run/podman/podman.sock <-> /var/run/docker.sock
- run `make bin/k3d`
- install the cluster with `make k3d/cluster_create`
- ???

More info [here](https://k3d.io/v5.4.6/usage/advanced/podman/)
