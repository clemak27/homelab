#!/bin/bash

project_dir=/var/home/clemens/Projects

# fix permissions
# ignition creates the keys.txt file, but the dir is owned by root
chown -R clemens:clemens /var/home/clemens/.config

# git repo
if [ ! -d "$project_dir/homelab" ]
then
  echo "Checking out homelab repo..."
  mkdir -p $project_dir
  cd $project_dir && git clone https://github.com/clemak27/homelab
  chown -R clemens:clemens $project_dir
  echo "Done"
fi

# prepare mountpoints for btrfs mounts
sudo mkdir -p /var/mnt/docker && sudo chown -R clemens:clemens /var/mnt/docker
sudo mkdir -p /var/mnt/archive && sudo chown -R clemens:clemens /var/mnt/archive
sudo mkdir -p /var/mnt/media && sudo chown -R clemens:clemens /var/mnt/media
sudo mkdir -p /var/mnt/emulation && sudo chown -R clemens:clemens /var/mnt/emulation
sudo mkdir -p /var/lib/docker
sudo mkdir -p /var/mnt/backups && sudo chown -R clemens:clemens /var/mnt/backups

# create mountpoints for nfs shares
sudo mkdir -p /var/nfs/media && sudo chown -R clemens:clemens /var/nfs/media

# start nfs service
systemctl restart nfs-server
systemctl enable nfs-server

# export nfs shares
exportfs -a
