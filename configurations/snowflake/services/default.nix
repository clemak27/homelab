{ config, pkgs, ... }:
{
  imports = [
    ./calibre.nix
    ./deemix.nix
    ./fireflyiii.nix
    ./gitea.nix
    ./homer.nix
    ./miniflux.nix
    ./monitoring.nix
    ./navidrome.nix
    ./pihole.nix
    ./jellyfin.nix
    ./recipes.nix
    ./syncthing.nix
    ./torrents.nix
    ./traefik.nix
    ./vaultwarden.nix
  ];

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
