{ config, pkgs, lib, ... }:
{
  imports = [
    ../i18n.nix
    ../nix.nix
    ../packages.nix
    ../ssh.nix
    ../user.nix

    # ./zsh.nix
  ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # if you have a Raspberry Pi 2 or 3, pick this:
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # A bunch of boot parameters needed for optimal runtime on RPi 3b+
  boot.kernelParams = [ "cma=256M" ];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=256
  '';

  # https://github.com/Robertof/nixos-docker-sd-image-builder/issues/24
  # boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_5_4;
  # boot.kernelParams = ["cma=64M"];

  # Preserve space by cleaning tmp dir
  boot.cleanTmpDir = true;

  networking.hostName = "winterberry";

  # Disable firewall
  networking.firewall.enable = false;

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  security.sudo.wheelNeedsPassword = false;


  # Use 2GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  swapDevices = [{ device = "/swapfile"; size = 2048; }];

  home-manager.useGlobalPkgs = true;
  home-manager.users.clemens = ./home.nix;

  system.stateVersion = "21.05";
}
