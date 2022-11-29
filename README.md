# my homelab setup

This repo the setup for my homelab.

It currently consists of a server running Fedora CoreOS.

## Structure

TODO

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
  - /var/run/docker.sock -> /run/podman/podman.sock

After that, you need to add `127.0.0.1   k3d.wallstreet30.local` to `/etc/hosts`.
Then you can deploy the local cluster with `make k3d`.
(I did not bother setting it up with rootless podman)

More info [here](https://k3d.io/v5.4.6/usage/advanced/podman/)

### GitOps

I deploy everything via GitOps, that is the current state of the k3s deployment repo
should be the same as defined in this git repo.
To do this is I use ArgoCD. The basic flow when setting up the cluster is as follows:

1. Create a cluster
2. Deploy ArgoCD via `helm install`
3. Apply a list of repositories (`k3s/services/repositories.yaml`)
4. Apply a list of applications (`k3s/services/applications.yaml`)
5. The 4th point deploys 2 things:
   - An Application managing ArgoCD itself (so it can sync changes to itself)
   - An ApplicationSet, that is built from all paths in `k3s/services/`

Due to the way ApplicationSets and Generators work, each directory in `k3s/services/`
contains a "fake" helm chart, that has the upstream helm-chart
I want to use as an dependency.

### Secret handling

I had good experiences with SOPS in the past,
so I continued to use it when migrating my setup to k8s.
ArgoCD has no integraded or recommended approach to handle secrets,
so it's up to the operator.

Since most things I want to deploy are available as helm-charts, I opted to use helm-secrets.
This stores the age private key as kubernetes secret, which is available to the `argocd-repo-server`.
When deploying applications, it decrypts the `secrets.yaml` in every service-folder
and adds it's values to the deployment.
