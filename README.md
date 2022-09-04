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
