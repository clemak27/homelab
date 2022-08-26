{ config, pkgs, ... }:
{
  systemd.services.gitops-update = {
    path = [
      pkgs.git
      pkgs.openssh
    ];
    serviceConfig = {
      User = "clemens";
      Type = "oneshot";
      ExecStart = ''${pkgs.git}/bin/git -C /home/clemens/Projects/homelab pull --rebase'';
    };
  };

  systemd.timers.gitops-update = {
    wantedBy = [ "timers.target" ];
    partOf = [ "gitops-update.service" ];
    timerConfig = {
      OnCalendar = [ "*-*-* *:*:00" ];
      Persistent = true;
    };
  };

  systemd.services.gitops-upgrade = {
    path = [
      pkgs.git
      pkgs.curl
      pkgs.tree
      pkgs.diffutils
      pkgs.nixVersions.nix_2_9
      pkgs.nixos-rebuild
      pkgs.inetutils
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.zsh}/bin/zsh -c "/home/clemens/gitops-upgrade.sh"'';
    };
  };

  systemd.timers.gitops-upgrade = {
    wantedBy = [ "timers.target" ];
    partOf = [ "gitops-upgrade.service" ];
    timerConfig = {
      OnCalendar = [ "*-*-* *:*:05" ];
      Persistent = true;
    };
  };


}
