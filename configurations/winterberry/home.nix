{ config, pkgs, lib, ... }:
{
  homecfg = {
    git = {
      enable = true;
      user = "clemak27";
      email = "clemak27@mailbox.org";
    };
    nvim.enable = false;
    tmux.enable = false;
    tools.enable = true;
    zsh.enable = true;
  };

  home.file."gitops-upgrade.sh".source = ../gitops-upgrade.sh;

  home.packages = with pkgs; [
    gcc
    neofetch
  ];

  home.stateVersion = "21.05";
}
