{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "miniflux";
  service-version = "2.0.37"; # renovate: datasource=docker depName=miniflux/miniflux
  service-port = "8081";
  internal-port = "8081";

  miniflux_admin_user = builtins.readFile "/run/secrets/docker/miniflux_admin_user";
  miniflux_admin_password = builtins.readFile "/run/secrets/docker/miniflux_admin_password";
  miniflux_db_name = "miniflux";
  miniflux_db_user = builtins.readFile "/run/secrets/docker/miniflux_db_user";
  miniflux_db_password = builtins.readFile "/run/secrets/docker/miniflux_db_password";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      miniflux = {
        image = "miniflux/miniflux:${service-version}";
        environment = {
          DATABASE_URL = "postgres://${miniflux_db_user}:${miniflux_db_password}@miniflux_db/${miniflux_db_name}?sslmode=disable";
          RUN_MIGRATIONS = "1";
          CREATE_ADMIN = "1";
          ADMIN_USERNAME = "${miniflux_admin_user}";
          ADMIN_PASSWORD = "${miniflux_admin_password}";
          BASE_URL = "https://miniflux.${config.servercfg.domain}";
          LISTEN_ADDR = "0.0.0.0:${internal-port}";
          POLLING_FREQUENCY = "15";
          BATCH_SIZE = "50";
        };
        ports = [
          "${service-port}:${internal-port}"
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
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${internal-port}"
        ];
        dependsOn = [ "miniflux_db" ];
      };

      miniflux_db = {
        image = "postgres:13.6"; # renovate: datasource=docker depName=postgres
        environment = {
          POSTGRES_USER = "${miniflux_db_user}";
          POSTGRES_PASSWORD = "${miniflux_db_password}";
        };
        volumes = [
          "${docker-data}/${service-name}_db:/var/lib/postgresql/data"
        ];
        extraOptions = [
          "--network=web"
          "--health-cmd=pg_isready -U ${miniflux_db_user} -d ${miniflux_db_name}"
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
