{ config, pkgs, lib, ... }:
{
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "clemens";

  environment.systemPackages = [
    (pkgs.kodi.passthru.withPackages (kodiPkgs: with kodiPkgs; [
      jellyfin
    ]))
  ];
}
