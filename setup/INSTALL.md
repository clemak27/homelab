# Homelab Setup

## Hosts

### aarch64-linux

<!-- markdownlint-disable-next-line -->
#### Preparation

- have a big enough microSD card (32 GB+)
- create new branch for host
- prepare config in hosts directory

#### Initial Setup

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD031 -->

##### RockPro64

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

After that, the device should be able to boot from the SD card.

##### Raspberry Pi 4B

Download the latest NixOS SD image from here:

[https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)
decompress it and write it to the SD card:

```sh
unzstd -d nixos-sd-image-23.11pre524605.3a2786eea085-aarch64-linux.img.zst
sudo dd if=nixos-sd-image-23.11pre524605.3a2786eea085-aarch64-linux.img of=/dev/sdX bs=4096 conv=fsync status=progress
```

After that, the device should be able to boot from the SD card.

#### Proper NixOS Setup

- Shutdown the device and insert the microSD in another device.
- Create `/etc/ssh/authorized_keys.d/nixos` and copy-paste at least one ssh
  public key inside of it.
- Insert the SD card back in the device, and you should now have ssh-access
  after booting is finished: `ssh nixos@<ip>`
- run `sudo nixos-generate-config` and update the config of the host if needed
- `sudo mkdir /home/clemens` this repo inside of it: `nix-shell -p git` and
  `sudo git clone https://github.com/clemak27/homelab.git`
- rebuild: `sudo nixos-rebuild boot --flake .#<hostname> --impure`
- reboot: `sudo Shutdown -r 0`
- after rebooting, you can connect with the `clemens` user with ssh
- use `sudo chown -R clemens:100 /home/clemens` to have the correct permissions
  and `sudo rm -rf /home/nixos` and `sudo rm /etc/ssh/authorized_keys.d/nixos`
  to clean up
- New generations can (and should) now be built remotely, e.g.:
  <!-- markdownlint-disable-next-line -->
  `sudo nixos-rebuild --impure --flake .#phobos --target-host clemens@<ip> switch`

#### Moving to an SSD

In some cases, it is preferably to install the system to an ssd for improved
performance. The rough outline to do this is:

- mount the SSD to use: `sudo mount /dev/sda1 /mnt`
- install NixOS to it:
  `sudo nixos-install --root /mnt --flake .#<hostname> --impure --no-root-password`
- generate a new config: `sudo nixos-generate-config --root /mnt`
- copy the generated boot-config to the SD card: `cp -R /mnt/boot/* /`
- update the `hardware-configuration.nix` of the host so the SD is mounted on
  `/boot` and the SSD on `/`
- hope it works :)

## k3s

`k3s` is installed as server by importing the `k3s-server.nix` module.

There are still some manual steps needed:

### kubeconfig

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD031 -->

1. Connect with ssh
2. On the server, run:
   ```sh
   mkdir -p /home/clemens/.kube
   cp /etc/rancher/k3s/k3s.yaml /home/clemens/.kube/config
   chown -R clemens:users /home/clemens/.kube
   ```
3. Copy `kubeconfig` to main PC:
   ```sh
   scp <ip>:/home/clemens/.kube/config /home/clemens/.kube/config
   ```
4. Edit the IP in the `kubeconfig` to match the server's IP.
<!-- markdownlint-restore -->

### ArgoCD

ArgoCD needs to be setup manually:

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD031 -->

1. Create the ArgoCD namespace:
   ```sh
   kubectl create namespace argocd
   ```
2. Create a secret with the age key:
   ```sh
   kubectl -n argocd create secret generic \
     argocd-age-key --from-literal keys.txt=AGE-SECRET-KEY-1234
   ```
3. Use helm for the initial ArgoCD deployment:
   ```sh
   helm repo add argo-cd https://argoproj.github.io/argo-helm
   kns argocd
   helm install argo-cd argo-cd/argo-cd --create-namespace --values ./cluster/argocd/argocd/values.yaml
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

### longhorn

All of my hosts use NixOS as OS. Since Nix does not adhere to the FSH standard,
longhorn doesn't work with it out of the box. It is usable with these steps:

- ssh to the host where it should run
- `cd` into `cluster/longhorn-system/longhorn`
- build the adapted image using the Dockerfile:
  `sudo docker build -t longhornio/longhorn-instance-manager-nix:v1.5.1 .`
- export the image to the internal registry of k3s:
  <!-- markdownlint-disable-next-line MD013 -->
  `sudo docker save longhornio/longhorn-instance-manager-nix:v1.5.1 | sudo k3s ctr images import -`
- the `kustomize.yaml` patches the upstream `longhorn.yaml` accordingly, and
  ArgoCD should deploy it successfully.
- this needs to be done on every worker node
