{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./k3s-server.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "nuke";

  system.stateVersion = "22.11";
}
