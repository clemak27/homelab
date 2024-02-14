{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./nfs.nix

    # ./k3s-agent.nix
    ./sops.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  hardware.enableAllFirmware = true;

  networking.hostName = "deimos";

  system.stateVersion = "23.05";

  swapDevices = [{
    device = "/swapfile";
    size = 8 * 1024;
  }];
}
