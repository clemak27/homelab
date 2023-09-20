{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./k3s-server.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # this is the lastest nixos kernel where usb3 works
  boot.kernelPackages = pkgs.linuxPackages_5_10;
  hardware.enableAllFirmware = true;

  networking.hostName = "ares";

  system.stateVersion = "23.05";

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;
  }];
}
