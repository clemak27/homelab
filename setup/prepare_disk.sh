#!/bin/sh

prepare_disk() {
  friendly_name="ssd"
  device="/dev/sdb"
  passphrase="abcd"

  partition="${device}1"
  luksMapper="crypt${friendly_name}"
  unencryptedDisk="/dev/mapper/${luksMapper}"

  parted --script "${device}" -- \
    mklabel gpt \
    mkpart primary btrfs 0% 100%

  # encrypt partition
  echo -n "${passphrase}" | cryptsetup -v luksFormat "${partition}" -
  echo -n "${passphrase}" | cryptsetup open "${partition}" "${luksMapper}" -

  # create filesystem
  mkfs.btrfs -L ${friendly_name} ${unencryptedDisk}

  # create subvolumes
  mkdir -p /tmp/mnt
  mount "${unencryptedDisk}" /tmp/mnt
  btrfs subvolume create /tmp/mnt/k3s
  btrfs subvolume create /tmp/mnt/longhorn
  umount /tmp/mnt

  cryptsetup luksClose ${unencryptedDisk}
}

mount_disk2() {
  partition="/dev/vda1"
  luksMapper="cryptData"
  unencryptedDisk="/dev/mapper/${luksMapper}"

  cryptsetup open "${partition}" "${luksMapper}"

  mkdir -p /var/mnt/media
  mkdir -p /var/mnt/backups

  mount -o compress=zstd,subvol=media $unencryptedDisk /var/mnt/media
  mount -o compress=zstd,subvol=backups $unencryptedDisk /var/mnt/backups

  mkdir -p /var/nfs/media
  mkdir -p /var/nfs/backups

  mount --bind /var/mnt/media /var/nfs/media
  mount --bind /var/mnt/backups /var/nfs/backups

  # sudo systemctl start nfs-server.service
}

##!/bin/sh

#set -e

#while true ; do
#uuid=$(journalctl -e | tail -n1 | grep -oP '(?<=orphaned pod \\")[^\\"]+')
#echo "$uuid"
#p="/var/lib/kubelet/pods/$uuid"
## p="/var/lib/kubelet/pods/$uuid/volumes/*"
## if [ -d "$p" ] ; then
#  # echo "Moving $uuid"
#  sudo mkdir -p /var/lib/kubelet/orphaned-pods/$uuid
#  sudo mv "$p" /var/lib/kubelet/orphaned-pods/$uuid
## fi
#sleep 2
#done
