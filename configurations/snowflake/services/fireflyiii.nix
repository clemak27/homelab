{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "fireflyiii";
  service-version = "version-5.6.16"; # renovate: datasource=docker depName=fireflyiii/core
  service-port = "8097";

  fireflyiii_app_key = builtins.readFile "${config.sops.secrets."docker/fireflyiii_app_key".path}";
  fireflyiii_db_name = builtins.readFile "${config.sops.secrets."docker/fireflyiii_db_name".path}";
  fireflyiii_db_user = builtins.readFile "${config.sops.secrets."docker/fireflyiii_db_user".path}";
  fireflyiii_db_password = builtins.readFile "${config.sops.secrets."docker/fireflyiii_db_password".path}";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      fireflyiii = {
        image = "fireflyiii/core:${service-version}";
        environment = {
          DB_CONNECTION = "pgsql";
          APP_KEY = "${fireflyiii_app_key}";
          APP_URL = "https://fireflyiii.${config.servercfg.domain}";
          TRUSTED_PROXIES = "**";
          DB_HOST = "fireflyiii_db";
          DB_PORT = "5432";
          DB_DATABASE = "${fireflyiii_db_name}";
          DB_USERNAME = "${fireflyiii_db_user}";
          DB_PASSWORD = "${fireflyiii_db_password}";
        };
        ports = [
          "${service-port}:8080"
        ];
        volumes = [
          "${docker-data}/${service-name}/upload:/var/www/html/storage/upload"
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
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=8080"
        ];
        dependsOn = [ "fireflyiii_db" ];
      };

      fireflyiii_db = {
        image = "postgres:13.6"; # renovate: datasource=docker depName=postgres
        environment = {
          POSTGRES_USER = "${fireflyiii_db_user}";
          POSTGRES_PASSWORD = "${fireflyiii_db_password}";
          POSTGRES_DB = "${fireflyiii_db_name}";
        };
        volumes = [
          "${docker-data}/${service-name}_db:/var/lib/postgresql/data"
        ];
        extraOptions = [
          "--network=web"
          "--health-cmd=pg_isready -U ${fireflyiii_db_user} -d ${fireflyiii_db_name}"
          "--health-start-period=30s"
          "--health-interval=10s"
        ];
      };
    };

    networking.extraHosts = ''
      192.168.178.100 ${service-name}.${config.servercfg.domain}
    '';
  };
}
