# Talos?

## local Setup

on host:

```sh
sudo docker run --rm -it \
  --name talos \
  --hostname mars \
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

setup extensions

```sh
curl -X POST --data-binary @lh-ext.yaml https://factory.talos.dev/schematics
# {"id":"613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"}
```

setup config

```sh
talosctl gen config local https://10.88.0.2:6443
talosctl apply-config --insecure --nodes 10.88.0.2 --file controlplane.yaml
talosctl bootstrap --nodes 10.88.0.2 --endpoints 10.88.0.2 --talosconfig=./talosconfig
talosctl kubeconfig --nodes 10.88.0.2 --endpoints 10.88.0.2 --talosconfig=./talosconfig
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
    --set operator.replicas=1 \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=false \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup

cilium status --wait
cilium connectivity test
# kubectl label namespace kube-system pod-security.kubernetes.io/enforce=privileged ???
```

be amazed it runs O.o

install lh

```sh
kubectl create namespace longhorn-system
kustomize build --enable-helm --enable-exec --enable-alpha-plugins cluster/longhorn-system/longhorn/ | kubectl apply -n longhorn-system -f -
```
