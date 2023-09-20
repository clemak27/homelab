{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./dnsmasq.nix
    ./sops.nix
    ./wireguard.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  hardware.enableAllFirmware = true;

  swapDevices = [{
    device = "/swapfile";
    size = 8 * 1024;
  }];

  networking.hostName = "phobos";

  system.stateVersion = "23.05";
}