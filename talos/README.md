# Talos?

## rpi4 setup

get the image:

```sh
curl -X POST --data-binary @./schematics/rpi4.yaml https://factory.talos.dev/schematics
# {"id":"3be8dcdb5d390122648d2336fc1e7a2dd584c8fc391492fc9ae009639b864a06"}
```

Download the image and decompress it

```sh
curl -LO https://factory.talos.dev/image/3be8dcdb5d390122648d2336fc1e7a2dd584c8fc391492fc9ae009639b864a06/v1.10.0/metal-arm64.raw.xz
xz -d metal-arm64.raw.xz
```

Write to SD Card:

```sh
sudo dd if=metal-arm64.raw of=/dev/sdc conv=fsync bs=4M
```

after it runs, apply the config

```sh
# phobos 192.168.178.102
talosctl gen config rpi https://192.168.178.102:6443
talosctl machineconfig patch controlplane.yaml --patch @./machineconfigs/rpi.yaml -o config.yaml
talosctl apply-config --insecure -n 192.168.178.102 -e 192.168.178.102 --file config.yaml
rm config.yaml
```

add to generated `talosconfig`:

```yaml
endpoints:
  - 192.168.178.102
nodes:
  - 192.168.178.102
```

get logs

```sh
talosctl dmesg -f
```

wait until logs show startup, then start k8s

```sh
talosctl bootstrap
talosctl kubeconfig
talosctl health
```

wait until everything is up → 🎉

## deploying and testing stuff

### redlib

simple service without any deps

```sh
k create namespace services
kns services
kustomize build --enable-helm ./cluster/services/redlib | k apply -n services -f -
kpf services/redlib 8080
```

works ✅

### cnpg

```sh
k create namespace cnpg-system
kns cnpg-system
kustomize build --enable-helm ./cluster/cnpg-system/cnpg | k create -n cnpg-system -f -
```

works ✅

### longhorn

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: longhorn-system
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/warn: privileged
    pod-security.kubernetes.io/warn-version: latest
```

FYI added `/var/lib/longhorn` to config and patched it:

```sh
talosctl patch mc --patch @./machineconfigs/rpi.yaml
```

```sh
kns longhorn-system
kustomize build --enable-helm --enable-exec --enable-alpha-plugins ./cluster/longhorn-system/longhorn | k create -n longhorn-system -f -
```

works ✅ (takes a while to boot tho)

### check HostDNS

- disable nodeLabel externalLB in mc
- label metallb namespace correctly (same as LH)
- deploy metallb
- deploy blocky

```sh
doggo miniflux.wallstreet30.cc -n 192.168.178.200:53
# NAME                            TYPE    CLASS   TTL     ADDRESS         NAMESERVER
# miniflux.wallstreet30.cc.       A       IN      3600s   192.168.178.100 192.168.178.200:53
```

works ✅

### check volumes

- mounting in /var/lib/longhorn works
- encryption requires `1.9.0`
  - https://github.com/siderolabs/talos/issues/10469
  - https://github.com/siderolabs/talos/issues/10473
- miniflux + db get deployed successfully 🎉

works ✅

### check ssd

- mount disk, see uservolume-zeugs
- create volume on disk in longhorn
- pod(s) can mounts rwx volume

```yaml
persistence:
  data:
    enabled: true
    existingClaim: media
    globalMounts:
      - path: /data
        readOnly: false
```

```sh
talosctl get machineconfig v1alpha1 -o jsonpath='{.spec}' > machineconfig.yaml
```

### check wireguard

- would need to run WG in a container :/ ->
  https://github.com/siderolabs/talos/issues/7184

### checkout flux?


