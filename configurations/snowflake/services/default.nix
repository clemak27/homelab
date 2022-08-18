{ config, pkgs, lib, ... }:
{
  imports = [
    ./calibre.nix
    ./cloudflare-ddns.nix
    # ./bumper.nix
    ./deemix.nix
    ./deconz.nix
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
  # logging with loki requires the plugin, which is not automated with nixos
  # https://github.com/NixOS/nixpkgs/issues/109372
  # docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
}
