# Talos?

## local Setup

on host:

```sh
sudo docker run --rm -it \
  --name talos \
  --hostname talos-cp \
  --read-only \
  --privileged \
  --security-opt seccomp=unconfined \
  --mount type=tmpfs,destination=/run \
  --mount type=tmpfs,destination=/system \
  --mount type=tmpfs,destination=/tmp \
  --mount type=volume,destination=/system/state \
  --mount type=volume,destination=/var \
  --mount type=volume,destination=/etc/cni \
  --mount type=volume,destination=/etc/kubernetes \
  --mount type=volume,destination=/usr/libexec/kubernetes \
  --mount type=volume,destination=/opt \
  -e PLATFORM=container \
  ghcr.io/siderolabs/talos:v1.10.0
```

setup config

```sh
# talosctl gen config local https://10.88.0.4:6443
talosctl apply-config --insecure --nodes 10.88.0.4 --file controlplane.yaml
talosctl bootstrap --nodes 10.88.0.4 --endpoints 10.88.0.4 --talosconfig=./talosconfig
talosctl kubeconfig --nodes 10.88.0.4 --endpoints 10.88.0.4 --talosconfig=./talosconfig

talosctl -n 10.88.0.4 -e 10.88.0.4 apply-config -f ./controlplane.yaml
```

install cilium

```sh
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install \
    cilium \
    cilium/cilium \
    --version 1.15.6 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=false \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup

cilium connectivity test
# kubectl label namespace kube-system pod-security.kubernetes.io/enforce=privileged ???
```

be amazed it runs O.o
