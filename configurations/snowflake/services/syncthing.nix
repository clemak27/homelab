{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "syncthing";
  service-version = "1.21.0"; # renovate: datasource=docker depName=syncthing/syncthing
  service-port = "8384";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      syncthing = {
        image = "syncthing/syncthing:${service-version}";
        ports = [
          "${service-port}:${service-port}"
          "22000:22000"
          "21027:21027/udp"
        ];
        volumes = [
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
          "${docker-data}/${service-name}/var:/var/syncthing"
          "${docker-data}/${service-name}/data:/data"
        ];
        log-driver = "loki";
        extraOptions = [
          "--network=web"
          "--security-opt=no-new-privileges:true"
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
