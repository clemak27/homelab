{ config, pkgs, ... }:
{
  systemd.services.mp3gain-update = {
    path = [
      pkgs.tree
      pkgs.diffutils
      pkgs.mp3gain
      pkgs.fd
      pkgs.curl
    ];
    serviceConfig = {
      User = "clemens";
      Type = "oneshot";
      ExecStart = ''${pkgs.zsh}/bin/zsh -c "/home/clemens/mp3gain-update.sh"'';
    };
  };

  systemd.timers.mp3gain-update = {
    wantedBy = [ "timers.target" ];
    partOf = [ "mp3gain-update.service" ];
    timerConfig = {
      OnCalendar = [ "*-*-* *:00:00" "*-*-* *:15:00" "*-*-* *:30:00" "*-*-* *:45:00" ];
      Persistent = true;
    };
  };
}
