# Homelab Setup

## Host

### Install

- [download the latest ISO](https://fedoraproject.org/iot/download)
- write to usb
- plug in and boot from it
- install fedora
- login into the installed system and add at least one ssh keys under
  `/home/clemens/.ssh/authorized_keys`

### Setup

- connect to device via ssh
- use `visudo` to setup pw-less sudo
- install everything:
  - check if all variables are correct
    - ip
    - dnsmasq interfaces
    - wg config
    - fstab
  - run these make targets:
    - `host/base`
    - `host/discs`
    - `host/config`
    - `host/k3s`
  - reboot to be sure

## k3s

There are some manual steps needed after k3s runs:

Edit the IP in the `k3sconfig.yaml` to match the server's IP, and add it to your
`kubeconfig`.

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
3. Use kustomize for the initial ArgoCD deployment:

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

   **Note:** It might be needed to add the kustomization-config to the
   configmap.

6. Delete the initial admin-secret:
   ```sh
   kubectl delete -n argocd secrets argocd-initial-admin-secret --ignore-not-found
   ```
7. You should now be able to log in to ArgoCD.
