{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./discs.nix
    # ./k3s-server.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "mars";

  system.stateVersion = "23.11";
}
