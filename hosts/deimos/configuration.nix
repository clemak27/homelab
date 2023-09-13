{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # ./mounts.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  hardware.enableAllFirmware = true;

  networking.hostName = "deimos";

  system.stateVersion = "23.05";
}
