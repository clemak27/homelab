{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";
  # whatever, it gets trashed soon anyway
  music-data = "/home/clemens/data0/media/music";

  service-name = "jellyfin";
  service-version = "10.8.4"; # renovate: datasource=docker depName=jellyfin/jellyfin
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
          "${music-data}:/media/music"
        ];
        log-driver = "loki";
        extraOptions = [
          "--network=web"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.${service-name}-router.entrypoints=https"
          "--label=traefik.http.routers.${service-name}-router.rule=Host(`${service-name}.${config.servercfg.domain}`)"
          "--label=traefik.http.routers.${service-name}-router.tls=true"
          "--label=traefik.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
          # HTTP Services
          "--label=traefik.http.routers.${service-name}-router.service=${service-name}-service"
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${internal-port}"
          # loki-logging
          "--log-opt=loki-url=http://192.168.178.100:3100/loki/api/v1/push"
          "--log-opt=loki-external-labels=job=${service-name}"
        ];
      };
    };

    networking.extraHosts = ''
      192.168.178.100 ${service-name}.${config.servercfg.domain}
    '';
  };
}
