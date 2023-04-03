{ config, pkgs, ... }:
let
  gitops = pkgs.writeShellScriptBin "gitops-run" ''
    set -eo pipefail

    homelab_dir="/home/clemens/homelab"

    if [ -e /run/systemd/shutdown/scheduled ]; then
      echo "skipping update due to scheduled reboot"
      exit 0
    fi

    sha256sum $homelab_dir/flake.lock > /tmp/flake_current
    tar c -P $homelab_dir/modules | sha256sum > /tmp/modules_current
    tar c -P $homelab_dir/hosts | sha256sum > /tmp/hosts_current

    export HOME="/"
    git config --global --add safe.directory $homelab_dir
    git -C $homelab_dir pull --rebase

    sha256sum $homelab_dir/flake.lock > /tmp/flake_new
    tar c -P $homelab_dir/modules | sha256sum > /tmp/modules_new
    tar c -P $homelab_dir/hosts | sha256sum > /tmp/hosts_new

    if ! cmp -s /tmp/flake_current /tmp/flake_new; then
      nixos-rebuild boot --impure --flake $homelab_dir 1> /dev/null
      shutdown -r 3:00
      echo "scheduled reboot"
    elif ! cmp -s /tmp/modules_current /tmp/modules_new; then
      nixos-rebuild switch --impure --flake $homelab_dir 1> /dev/null
    elif ! cmp -s /tmp/hosts_current /tmp/hosts_new; then
      nixos-rebuild switch --impure --flake $homelab_dir 1> /dev/null
    fi
  '';
in
{
  systemd.services.gitops = {
    path = [
      pkgs.curl
      pkgs.diffutils
      pkgs.git
      pkgs.inetutils
      pkgs.nixVersions.stable
      pkgs.nixos-rebuild
      pkgs.gnutar
      gitops
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${gitops}/bin/gitops-run'';
    };
  };

  systemd.timers.gitops = {
    wantedBy = [ "timers.target" ];
    partOf = [ "gitops.service" ];
    timerConfig = {
      OnCalendar = [ "*-*-* *:*:05" ];
      Persistent = true;
    };
  };
}
