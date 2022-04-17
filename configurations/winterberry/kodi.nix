{ config, pkgs, lib, ... }:
{
  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;
  services.cage.user = "kodi";
  services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  services.cage.enable = true;

  environment.systemPackages = [
    (pkgs.kodi.passthru.withPackages (kodiPkgs: with kodiPkgs; [
      jellyfin
    ]))
  ];
}
