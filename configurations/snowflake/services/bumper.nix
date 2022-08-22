{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "bumper";
  service-version = "latest";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      bumper = {
        image = "bmartin5692/bumper:${service-version}";
        environment = {
          BUMPER_ANNOUNCE_IP = "192.168.178.100";
          # BUMPER_LISTEN = "192.168.178.100";
          BUMPER_LISTEN = "0.0.0.0";
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Rome";
          LOG_TO_STDOUT = "true";
          BUMPER_DEBUG = "true";
        };
        ports = [
          # "443:443"
          "8007:8007"
          "8883:8883"
          "5223:5223"
        ];
        volumes = [
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
          "${docker-data}/${service-name}/data:/bumper/data"
          "${docker-data}/${service-name}/certs:/bumper/certs"
          "${docker-data}/${service-name}/logs:/bumper/logs"
        ];
        extraOptions = [
          "--network=web"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.bumper-insecure.entrypoints=http"
          "--label=traefik.http.routers.bumper-insecure.rule=HostRegexp(`{subdomain:[a-z0-9._-]+}.ecovacs.net`, `{subdomain:[a-z0-9._-]+}.ecovacs.com`, `{subdomain:[a-z0-9._-]+}.ecouser.net`)"
          "--label=traefik.http.routers.bumper-insecure.middlewares=bumper-https@docker"
          "--label=traefik.http.routers.bumper.entrypoints=https"
          "--label=traefik.http.routers.bumper.tls.certresolver=letsEncrypt"
          "--label=traefik.http.routers.bumper.tls=true"
          "--label=traefik.http.routers.bumper.tls.domains[0].main=ecovacs.net"
          "--label=traefik.http.routers.bumper.tls.domains[0].sans=*.ecovacs.net"
          "--label=traefik.http.routers.bumper.rule=HostRegexp(`{subdomain:[a-z0-9._-]+}.ecovacs.net`, `{subdomain:[a-z0-9._-]+}.ecovacs.com`, `{subdomain:[a-z0-9._-]+}.ecouser.net`)"
          "--label=traefik.http.services.bumper.loadbalancer.server.port=80"
          "--label=traefik.http.middlewares.bumper-https.redirectscheme.scheme=https"
        ];
      };
    };
  };
}
