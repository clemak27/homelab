#!/bin/sh

prepare_disk() {
  friendly_name="ssd"
  device="/dev/sdb"
  passphrase="thisIsNotAGoodPassphrase"

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
  btrfs subvolume create /tmp/mnt/media
  btrfs subvolume create /tmp/mnt/backups
  umount /tmp/mnt

  cryptsetup luksClose ${unencryptedDisk}
}

prepare_disk
