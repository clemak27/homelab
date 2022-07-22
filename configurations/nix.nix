{ config, pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.nix_2_9;
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
   extraOptions = ''
     experimental-features = nix-command flakes
   '';
  };

  documentation.nixos.enable = false;
}
