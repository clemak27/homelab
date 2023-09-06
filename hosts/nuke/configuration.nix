{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./dnsmasq.nix
    ./mounts.nix
    ./sops.nix
    ./wireguard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "nuke";

  system.stateVersion = "22.11";
}
