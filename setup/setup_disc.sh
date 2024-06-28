#!/bin/sh
# shellcheck disable=3010
# shellcheck disable=3037

# ------------------------------------- config -------------------------------------

device="/dev/vda"
hostname="boltzmann"

# ------------------------------------- functions ----------------------------------

if [[ $device =~ "nvme" ]]; then
  bootPartition="${device}p1"
  rootPartition="${device}p2"
else
  bootPartition="${device}1"
  rootPartition="${device}2"
fi

rootVolume="/dev/lvm/root"
swapSize=8192

# Setup the disk and partitions
parted --script "${device}" -- \
  mklabel gpt \
  mkpart ESP fat32 1MiB 512MiB \
  set 1 esp on \
  mkpart primary btrfs 512MiB 100%

# Create the lvm
pvcreate "${rootPartition}"
vgcreate lvm "${rootPartition}"
lvcreate --extents 100%FREE --name root lvm

# create filesystems
mkfs.fat -F 32 -n boot "${bootPartition}"
mkfs.btrfs -L nixos ${rootVolume}

# create subvolumes
mkdir -p /mnt
mount "${rootVolume}" /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/swap
umount /mnt

# Mount the partitions and subvolumes
mount -o compress=zstd,subvol=root $rootVolume /mnt
mkdir -p /mnt/nix
mkdir -p /mnt/swap
mount -o compress=zstd,noatime,subvol=nix $rootVolume /mnt/nix
mount -o subvol=swap $rootVolume /mnt/swap

# Create the swap file with copy-on-write and compression disabled:
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
btrfs property set /mnt/swap compression none
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=$swapSize
chmod 0600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile

# Mount the boot partition
mkdir /mnt/boot
mount $bootPartition /mnt/boot

# Generate the NixOS config
nixos-generate-config --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix > "../hosts/$hostname/hardware-configuration.nix"
