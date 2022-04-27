{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data0/docker";

  service-name = "home-assistant";
  service-version = "2022.4"; # renovate: datasource=docker depName=homeassistant/home-assistant
  service-port = "8123";
  internal-port = "8123";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      home-assistant = {
        image = "homeassistant/home-assistant:${service-version}";
        ports = [
          "${service-port}:${internal-port}"
        ];
        environment = {
          TZ = "Europe/Vienna";
        };
        volumes = [
          "${docker-data}/${service-name}:/config"
        ];
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
        # extraOptions = [
        #   "--network=web"
        #   "--label=traefik.enable=true"
        #   "--label=traefik.http.routers.${service-name}-router.entrypoints=https"
        #   "--label=traefik.http.routers.${service-name}-router.rule=Host(`${service-name}.hemvist.duckdns.org`)"
        #   "--label=traefik.http.routers.${service-name}-router.tls=true"
        #   "--label=traefik.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
        #   # HTTP Services
        #   "--label=traefik.http.routers.${service-name}-router.service=${service-name}-service"
        #   "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${internal-port}"
        # ];
      };
    };

  networking.extraHosts = ''
      192.168.178.100 ${service-name}.hemvist.duckdns.org
    '';

  };
}
