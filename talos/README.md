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

add to generated talosconfig:

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
```

wait until everything is up -> 🎉
