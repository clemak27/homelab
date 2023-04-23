# Homelab Setup

## Setup

### Bare-metal

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

### k3s

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
7. You should now be able to log in to ArgoCD and watch all applications syncing.
<!-- markdownlint-restore -->

<!-- ### longhorn -->
<!-- TODO spicy nixOS stuff -->
