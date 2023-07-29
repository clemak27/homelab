# Homelab Setup

## Hosts

### x86_64-linux

#### Preparation

- create live USB (if there is none yet)
- create new branch for host
- prepare config in hosts directory

#### NixOS install

- boot from live USB
- follow the GUI setup, install on DE
- reboot into new system

#### Configuring the system

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

### aarch64-linux

<!-- markdownlint-disable-next-line -->
#### Preparation

- have a big enough microSD card (32 GB+)
- create new branch for host
- prepare config in hosts directory

#### Initial Setup

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD031 -->

- we need to build an image for the system:
- checkout [nixos-aarch64-images](https://github.com/Mic92/nixos-aarch64-images)
  locally
- building the `uboot` and `idbloader` images locally didn't work:
  - download the latest builds from
    [hydra](https://hydra.nixos.org/job/nixpkgs/trunk/ubootRockPro64.aarch64-linux)
  - save it e.g. in the path of the git repo
  - add this path to the nix store: `nix store add-path .`
  - add this path to the `let` block in `rockchip.nix`:
    ```nix
    let
      ...
      uboot = /nix/store/kqh7j0hzr2wl4mgm82x0wglrw5j5bgz8-.;
    in
    ```
- update the aarch64 image that is used:
  - run
    `curl -s -L -I -o /dev/null -w '%{url_effective}' "https://hydra.nixos.org/job/nixos/release-23.05/nixos.sd_image.aarch64-linux/latest/download/1"`
  - replace `url` and `hash` in `aarch64-image/default.nix`
  <!-- markdownlint-disable-next-line -->
- `nix build --no-write-lock-file --override-input nixpkgs github:nixos/nixpkgs/nixpkgs-unstable .#rockPro64 --impure`
- `sudo dd if=./result of=/dev/sda iflag=direct oflag=direct bs=16M status=progress`

<!-- markdownlint-restore -->

After that, the device should be able to boot from the SD card.

#### Proper NixOS Setup

- Shutdown the device and insert the microSD in another device.
- Create `/etc/ssh/authorized_keys.d/nixos` and copy-paste at least one ssh
  public key inside of it.
- Insert the SD card back in the device, and you should now have ssh-access
  after booting is finished: `ssh nixos@<ip>`
- run `sudo nixos-generate-config` and update the config of the host if needed
- `sudo mkdir /home/clemens` this repo inside of it: `nix-shell -p git` and
  `git clone https://github.com/clemak27/homelab.git --branch=feat/add-pine64`
- rebuild: `sudo nixos-rebuild boot --flake .#armadillo --impure` (change the
  hostname accordingly)
- after rebooting, you can connect with the `clemens` user with ssh
- use `sudo chown -R clemens:100 /home/clemens` to have the correct permissions
  and `sudo rm -rf /home/nixos` to cleanup
- New generations can (and should) now be built remotely, e.g.:
  <!-- markdownlint-disable-next-line -->
  `sudo nixos-rebuild --impure --flake .#armadillo --target-host clemens@10.0.0.3  switch`

## k3s

`k3s` is installed as server by enabling the `k3s.nix` module.

There are still some manual steps needed:

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD031 -->

1. Connect with ssh
2. On the server, run:
   ```sh
   mkdir -p /var/home/clemens/.kube
   cp /etc/rancher/k3s/k3s.yaml /var/home/clemens/.kube/config
   chown -R clemens:clemens /var/home/clemens/.kube
   ```
3. Copy kubeconfig to main PC:
   ```sh
   scp <ip>:/home/clemens/.kube/config /var/home/clemens/.kube/config
   ```
4. Edit the IP in the kubeconfig to match the server's ip.
<!-- markdownlint-restore -->

#### ArgoCD

ArgoCD needs to be setup manually:

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD031 -->

1. Create the ArgoCD namespace:
   ```sh
   kubectl create namespace argocd
   ```
2. Create a secret with the age key:
   ```sh
   kubectl -n argocd create secret generic && \
     argocd-age-key --from-literal keys.txt=AGE-SECRET-KEY-1234
   ```
3. Use helm for the initial ArgoCD deployment:
   ```sh
   helm repo add argo-cd https://argoproj.github.io/argo-helm
   helm install -n argocd argo-cd/argo-cd --values ./cluster/argocd/argocd/values.yaml
   ```
4. Wait until everything is healthy (should take max 2 minutes)
5. Create all ArgoCD applications:
   <!-- markdownlint-disable-next-line -->
   ```sh
   find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;
   ```
6. Delete the initial admin-secret:
   ```sh
   kubectl delete -n argocd secrets argocd-initial-admin-secret
   ```
7. You should now be able to log in to ArgoCD and watch all applications
syncing.
<!-- markdownlint-restore -->

<!-- ### longhorn -->
<!-- TODO spicy nixOS stuff -->
