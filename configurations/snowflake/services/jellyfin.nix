{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data0/docker";

  service-name = "jellyfin";
  service-version = "10.7.7"; # renovate: datasource=docker depName=jellyfin/jellyfin
  service-port = "8098";
  internal-port = "8096";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      jellyfin = {
        image = "jellyfin/jellyfin:${service-version}";
        ports = [
          "${service-port}:${internal-port}"
          "8920:8920/tcp"
          "1900:1900/udp"
          "7359:7359/udp"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
        };
        volumes = [
          "${docker-data}/jellyfin/config:/config"
          "${docker-data}/jellyfin/cache:/cache"
          "${docker-data}/jellyfin/media/movies:/media/movies"
          "${docker-data}/jellyfin/media/series:/media/series"
          "${docker-data}/jellyfin/media/music:/media/music"
        ];
        extraOptions = [
          "--network=web"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.${service-name}-router.entrypoints=https"
          "--label=traefik.http.routers.${service-name}-router.rule=Host(`${service-name}.hemvist.duckdns.org`)"
          "--label=traefik.http.routers.${service-name}-router.tls=true"
          "--label=traefik.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
          # HTTP Services
          "--label=traefik.http.routers.${service-name}-router.service=${service-name}-service"
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${internal-port}"
        ];
      };
    };

    networking.extraHosts = ''
      192.168.178.100 ${service-name}.hemvist.duckdns.org
    '';
  };
}
