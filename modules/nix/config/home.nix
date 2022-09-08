{ config, pkgs, lib, ... }:
let
  updateHM = pkgs.writeShellScriptBin "update-homecfg" ''
    echo "Updating flake"
    nix flake update
    git add flake.nix flake.lock
    git commit -m "chore(flake): Update $(date -I)"

    echo "Reloading home-manager config"
    home-manager switch --flake '/var/home/clemens/Projects/homelab/modules/nix/config'

    echo "Collecting garbage"
    nix-collect-garbage

    echo "Updating tealdeer cache"
    tldr --update

    echo "Updating nvim plugins"
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
  '';
in
{
  homecfg = {
    dev.enable = true;
    fun.enable = false;
    k8s.enable = false;
    git = {
      enable = true;
      user = "clemak27";
      email = "clemak27@mailbox.org";
      tea = true;
      gh = true;
      glab = false;
    };
    nvim.enable = true;
    tmux.enable = true;
    tools.enable = true;
    zsh.enable = true;
  };

  programs.zsh = {
    shellAliases = builtins.listToAttrs (
      [
        { name = "docker"; value = "/usr/bin/flatpak-spawn --host podman"; }
        { name = "hms"; value = "home-manager switch --flake '/var/home/clemens/Projects/homelab/modules/nix/config'"; }
        { name = "hmsl"; value = "home-manager switch --flake '/var/home/clemens/Projects/homelab/modules/nix/config' --override-input homecfg 'path:/home/clemens/Projects/homecfg'"; }
        { name = "podman"; value = "/usr/bin/flatpak-spawn --host podman"; }
        { name = "prcwd"; value = "/usr/bin/flatpak-spawn --host podman run --interactive --rm --security-opt label=disable --volume $(pwd):/pwd --workdir /pwd"; }
        { name = "rh"; value = "/usr/bin/flatpak-spawn --host"; }
        { name = "rhs"; value = "/usr/bin/flatpak-spawn --host sudo -S"; }
        { name = "tam"; value = "tmux new-session -A -D -s remote -c ~ -n remote"; }
      ]
    );

    initExtra = ''
      # nix home-manager init
      . $HOME/.nix-profile/etc/profile.d/nix.sh
      export GIT_SSH=/usr/bin/ssh

      # autostart tmux
      if tmux info &> /dev/null; then
        tmux start-server
      fi
    '';
  };

  # https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
}
