#!/bin/bash

# renovate: datasource=github-tags depName=k3s-io/k3s/releases versioning=loose
export INSTALL_K3S_VERSION=v1.35.0+k3s3

curl -sfL https://get.k3s.io | sh -
mkdir -p /var/home/core/.kube
cp /etc/rancher/k3s/k3s.yaml /var/home/core/.kube/config
chown -R core:core /var/home/core/.kube
systemctl enable --now k3s.service
