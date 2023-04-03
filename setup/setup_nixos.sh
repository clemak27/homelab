#!/bin/sh

# ------------------------------------- config -------------------------------------

device="/dev/vda"
hostname="virtual"

# ------------------------------------- functions ----------------------------------

if [[ $device =~ "nvme" ]]; then
  rootPartition="${device}p1"
  swapPartition="${device}p2"
  bootPartition="${device}p3"
else
  rootPartition="${device}1"
  swapPartition="${device}2"
  bootPartition="${device}3"
fi

parted $device -- mklabel gpt

# root
parted $device -- mkpart primary 512MiB -8GiB

# swap
parted $device -- mkpart primary linux-swap -8GiB 100%

# boot
parted $device -- mkpart ESP fat32 1MiB 512MiB
parted $device -- set 3 esp on

# root
mkfs.ext4 -L nixos $rootPartition

# swap
mkswap -L swap $swapPartition

# boot
mkfs.fat -F 32 -n boot $bootPartition

# Mount root
mount $rootPartition /mnt

# Mount boot
mkdir -p /mnt/boot
mount $bootPartition /mnt/boot

# Generate the NixOS config
nixos-generate-config --root /mnt

# overwrite the configuration.nix
cp /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix.bu
cat << 'EOF' > /mnt/etc/nixos/configuration.nix
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.openssh.enable = true;

  users.users.clemens = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    password = "1234";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCyRaO8psuZI2i/+inKS5jn765Uypds8ORj/nVkgSE3 argentum"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3PSHWVz5/LwHEEfo+7y2o5KH7dlLyfySWnyyi7LLxe silfur"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsk9Bh5+4ZsEDFGb7mXDiClvsLwM+jMNr+SPf+auyu7 enchilada"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA35xMqpMFnqqkPUyDR5KMNQsDMkEKQLIvyvMk0HzVux nuke"
    ];
  };

  environment.systemPackages = with pkgs; [
    zsh
    vim
    wget
    curl
    w3m
    git
    parted
  ];

  networking.networkmanager.enable = true;
  system.stateVersion = "22.11";

  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "de";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
EOF
{
  echo
  echo "  networking.hostName = \"$hostname\";"
  echo "}"
} >> /mnt/etc/nixos/configuration.nix

nixos-install
# shutdown -r 0
