{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data0/docker";

  service-name = "vaultwarden";
  service-version = "1.24.0"; # renovate: datasource=docker depName=vaultwarden/server
  service-port = "8800";
  internal-port = "80";

  vaultwarden_yubico_client_id = builtins.readFile "/run/secrets/docker/vaultwarden_yubico_client_id";
  vaultwarden_yubico_secret_key = builtins.readFile "/run/secrets/docker/vaultwarden_yubico_secret_key";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      vaultwarden = {
        image = "vaultwarden/server:${service-version}";
        ports = [
          "${service-port}:${internal-port}"
        ];
        environment = {
          UID = "1000";
          GID = "1000";
          YUBICO_CLIENT_ID = "${vaultwarden_yubico_client_id}";
          YUBICO_SECRET_KEY = "${vaultwarden_yubico_secret_key}";
        };
        volumes = [
          "${docker-data}/vaultwarden:/data"
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
  };
}
