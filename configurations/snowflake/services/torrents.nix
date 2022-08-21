{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";
  torrent-path = "${config.servercfg.data_dir}/torrents";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      transmission =
        let
          service-name = "transmission";
          service-version = "version-3.00-r2"; # renovate: datasource=docker depName=linuxserver/transmission
          service-port = "9091";
        in
        {
          image = "linuxserver/transmission:${service-version}";
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Europe/vienna";
          };
          volumes = [
            "${docker-data}/${service-name}:/config"
            "${torrent-path}:/downloads"
          ];
          ports = [
            "${service-port}:${service-port}"
            "49153:49153"
            "49153:49153/udp"
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
            "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${service-port}"
          ];
        };
      jackett =
        let
          service-name = "jackett";
          service-version = "0.20.1768"; # renovate: datasource=docker depName=linuxserver/jackett
          service-port = "9117";
        in
        {
          image = "linuxserver/jackett:${service-version}";
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Europe/vienna";
          };
          volumes = [
            "${docker-data}/${service-name}:/config"
            "${torrent-path}/completed:/downloads"
          ];
          ports = [
            "${service-port}:${service-port}"
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
            "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${service-port}"
          ];
        };
      sonarr =
        let
          service-name = "sonarr";
          service-version = "3.0.9"; # renovate: datasource=docker depName=linuxserver/sonarr
          service-port = "8989";
        in
        {
          image = "linuxserver/sonarr:${service-version}";
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Europe/vienna";
          };
          volumes = [
            "${docker-data}/${service-name}:/config"
            "${torrent-path}:/downloads"
            "${docker-data}/jellyfin/media/series:/downloads/series"
          ];
          ports = [
            "${service-port}:${service-port}"
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
            "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${service-port}"
          ];
        };

      radarr =
        let
          service-name = "radarr";
          service-version = "4.1.0"; # renovate: datasource=docker depName=linuxserver/radarr
          service-port = "7878";
        in
        {
          image = "linuxserver/radarr:${service-version}";
          environment = {
            PUID = "1000";
            PGID = "1000";
            TZ = "Europe/vienna";
          };
          volumes = [
            "${docker-data}/${service-name}:/config"
            "${torrent-path}:/downloads"
            "${docker-data}/jellyfin/media/movies:/downloads/movies"
          ];
          ports = [
            "${service-port}:${service-port}"
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
            "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${service-port}"
          ];
        };
    };

    networking.extraHosts = ''
      192.168.178.100 transmission.${config.servercfg.domain}
      192.168.178.100 jackett.${config.servercfg.domain}	
      192.168.178.100 sonarr.${config.servercfg.domain}	
      192.168.178.100 radarr.${config.servercfg.domain}
    '';
  };
}
