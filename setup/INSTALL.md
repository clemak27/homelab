# Homelab Setup

## Setup

### Preparation

- create live USB (if there is none yet)
- create new branch for host
- prepare config in hosts directory

### NixOS install

- boot from live USB
- follow the GUI setup, install on DE
- reboot into new system

### Configuring the system

- Login as normal user
- Connect with ssh
- Checkout repo: `git clone https://github.com/clemak27/homelab.git`
- Copy over the age key: `scp key.txt clemens@<ip>:/home/clemens/homelab/`
- Run the `./setup_system.sh` script
- Copy over the adapted configs:
  `scp -r clemens@<ip>:/home/clemens/homelab/hosts/<hostname> ./hosts`
- Push a commit with the updated configs
- Reset the git repo on the server to its original state and pull
- Make sure WireGuard is disabled and run

```sh
sudo nixos-rebuild boot --impure --flake .
```

- reboot
- enable WireGuard and run

```sh
sudo nixos-rebuild switch --impure --flake .
```
