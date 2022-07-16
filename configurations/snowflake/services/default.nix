{ config, pkgs, lib, ... }:
{
  imports = [
    ./calibre.nix
    ./cloudflare-ddns.nix
    ./deemix.nix
    ./fireflyiii.nix
    ./gitea.nix
    ./home-assistant.nix
    ./homer.nix
    ./jellyfin.nix
    ./miniflux.nix
    ./monitoring.nix
    ./mqtt.nix
    ./pihole.nix
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
