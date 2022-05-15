{ config, pkgs, lib, ... }:
{
  imports = [
    ../gitops.nix
    ../i18n.nix
    ../nix.nix
    ../packages.nix
    ../ssh.nix
    ../user.nix

    ./hardware-configuration.nix
    ./mounts.nix
    ./sops.nix
    ./swapfile.nix
    ./wireguard.nix

    ./services
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Prevent notbook from sleeping when lid is closed
  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
    HandleLidSwitchExternalPower=ignore
    LidSwitchIgnoreInhibited=no
  '';

  networking.hostName = "snowflake";
  networking.interfaces.enp4s0.useDHCP = true;

  # Enable NAT
  networking.nat = {
    enable = true;
    externalInterface = "enp4s0";
    internalInterfaces = [ "wg0" ];
  };

  # Disable firewall
  networking.firewall.enable = false;

  home-manager.useGlobalPkgs = true;
  home-manager.users.clemens = ./home.nix;

  system.stateVersion = "21.05";
}
