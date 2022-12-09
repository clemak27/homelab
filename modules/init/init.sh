#!/bin/bash

project_dir=/var/home/clemens/Projects

# fix permissions
# ignition creates the keys.txt file, but the dir is owned by root
chown -R clemens:clemens /var/home/clemens/.config

# git repo
if [ ! -d "$project_dir/homelab" ]; then
  echo "Checking out homelab repo..."
  mkdir -p $project_dir
  cd $project_dir && git clone https://github.com/clemak27/homelab
  chown -R clemens:clemens $project_dir
  echo "Done"
fi

# prepare mountpoints for btrfs mounts
mkdir -p /var/mnt/docker && chown -R clemens:clemens /var/mnt/docker
mkdir -p /var/mnt/archive && chown -R clemens:clemens /var/mnt/archive
mkdir -p /var/mnt/media && chown -R clemens:clemens /var/mnt/media
mkdir -p /var/mnt/emulation && chown -R clemens:clemens /var/mnt/emulation
mkdir -p /var/lib/docker
mkdir -p /var/mnt/backups && chown -R clemens:clemens /var/mnt/backups

# create mountpoints for nfs shares
mkdir -p /var/nfs/archive && chown -R clemens:clemens /var/nfs/archive
mkdir -p /var/nfs/media && chown -R clemens:clemens /var/nfs/media
mkdir -p /var/nfs/emulation && chown -R clemens:clemens /var/nfs/emulation

# start nfs service
systemctl restart nfs-server
systemctl enable nfs-server

# export nfs shares
exportfs -a

# init k3s
curl -sfL https://get.k3s.io | sh -
mkdir -p /var/home/clemens/.kube
cp /etc/rancher/k3s/k3s.yaml /var/home/clemens/.kube/config
chown -R clemens:clemens /var/home/clemens/.kube
# copy kube-config to main PC
# scp 192.168.178.101:/home/clemens/.kube/config /var/home/clemens/.kube/config
# edit the IP in the kubeconfig and edit /etc/hosts if necessary
# install argocd by runnin make k3s/init_argocd
