# Homelab Setup

## Host

### Preparation

- create live USB (if there is none yet)
- create new branch for host
- prepare config in hosts directory

### NixOS install

- boot from live USB
- Open a terminal and checkout the repo:
  `git clone https://github.com/clemak27/homelab`
- `cd homelab/setup`
- update `setup_disc.sh` with the device where nix should be installed (check
  with `lsblk`)
- run `sudo ./setup_disc.sh`
- comment out all modules that requires sops (e.g. WireGuard)
- Install NixOS with
  `sudo nixos-install --root /mnt --flake .#<hostname> --impure --no-root-password`
- reboot

### First Boot

- you should now be able to connect via ssh
- copy the updated/current hw-config to the host:
  `scp clemens@192.168.178.100:/etc/nixos/hardware-configuration.nix ./hosts/<hostname>/hardware-configuration.nix`
- set up sops/sops-nix by copying a valid key to the server:
  `scp key.txt clemens@192.168.178.100:key.txt`
- Disable the WireGuard module and other modules requiring sops
- Rebuild with
  `nixos-rebuild --use-remote-sudo --impure --flake .#boltzmann --target-host clemens@$(IP) boot`
  and the reboot
- Enable the WireGuard module and other modules requiring sops
- Rebuild with
  `nixos-rebuild --use-remote-sudo --impure --flake .#boltzmann --target-host clemens@$(IP) boot`
  and the reboot
- everything should work now

## k3s

There are some manual steps needed to setup k3s runs:

- Copy over the kubeconfig:
  `scp clemens@192.168.178.100:/etc/rancher/k3s/k3s.yaml k3sconfig.yaml`
- Edit the IP in the `k3sconfig.yaml` to match the server's IP, and add it to
  your `kubeconfig`.

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
3. Use `kustomize` for the initial ArgoCD deployment:

   ```sh
    make bin/ksops
    KUSTOMIZE_PLUGIN_HOME=$PWD/bin/kustomize/plugin kustomize build --enable-helm --enable-exec --enable-alpha-plugins cluster/argocd/argocd/ > argocd.yaml
    kubectl apply -f argocd.yaml
   ```

4. Wait until everything is healthy (should take max 2 minutes)
5. Create the ArgoCD application properly:
   <!-- markdownlint-disable-next-line -->

   ```sh
   kubectl -n argocd apply -f cluster/argocd/applications.yaml
   ```

   **Note:** It might be needed to add
   `kustomize.buildOptions: --enable-alpha-plugins --enable-exec --enable-helm`
   to the `argocd-cm` configmap via edit.

6. Delete the initial admin-secret:
   ```sh
   kubectl delete -n argocd secrets argocd-initial-admin-secret --ignore-not-found
   ```
7. You should now be able to log in to ArgoCD.
