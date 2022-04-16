{ config, pkgs, lib, ... }:
{
  users.users.clemens = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
}
