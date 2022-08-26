{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";
  # whatever, it gets trashed soon anyway
  music-data = "/home/clemens/data0/media/music";

  service-name = "deemix";
  service-version = "latest";
  service-port = "6595";

  deemix_arl = builtins.readFile "${config.sops.secrets."docker/deemix_arl".path}";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      deemix = {
        image = "registry.gitlab.com/bockiii/deemix-docker:${service-version}";
        ports = [
          "${service-port}:${service-port}"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          ARL = "${deemix_arl}";
        };
        volumes = [
          "${docker-data}/deemix/config:/config"
          "${music-data}:/downloads"
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
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${service-port}"
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
