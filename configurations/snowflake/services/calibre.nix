{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      calibre-web =
        let
          service-name = "calibre";
          service-version = "2021.12.16"; # renovate: datasource=docker depName=lscr.io/linuxserver/calibre-web
          service-port = "8084";
        in
        {
          image = "lscr.io/linuxserver/calibre-web:${service-version}";
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Europe/vienna";
            # DOCKER_MODS="linuxserver/calibre-web:calibre";
          };
          ports = [
            "${service-port}:8083"
          ];
          volumes = [
            "${docker-data}/${service-name}/config-web:/config"
            "${docker-data}/${service-name}/books:/books"
          ];
          extraOptions = [
            "--network=web"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.${service-name}-router.entrypoints=https"
            "--label=traefik.http.routers.${service-name}-router.rule=Host(`${service-name}.${config.servercfg.domain}`)"
            "--label=traefik.http.routers.${service-name}-router.tls=true"
            "--label=traefik.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
            # HTTP Services
            "--label=traefik.http.routers.${service-name}-router.service=${service-name}-service"
            "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=8083"
          ];
        };
      calibre =
        let
          service-name = "calibre";
          service-version = "5.43.0"; # renovate: datasource=docker depName=lscr.io/linuxserver/calibre
        in
        {
          image = "lscr.io/linuxserver/calibre:${service-version}";
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Europe/vienna";
            # DOCKER_MODS="linuxserver/calibre-web:calibre";
          };
          ports = [
            "8095:8080"
            "8096:8081"
          ];
          volumes = [
            "${docker-data}/${service-name}/config:/config"
            "${docker-data}/${service-name}/books:/books"
          ];
          extraOptions = [
            "--network=web"
          ];
        };
    };

    networking.extraHosts = ''
      192.168.178.100 calibre.${config.servercfg.domain}
    '';
  };
}
