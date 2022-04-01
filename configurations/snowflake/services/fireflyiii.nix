{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data/docker";

  service-name = "fireflyiii";
  service-version = "version-5.6.16"; # renovate: datasource=docker depName=fireflyiii/core
  service-port = "8097";

  fireflyiii_app_key = builtins.readFile "/run/secrets/docker/fireflyiii_app_key";
  fireflyiii_db_name = builtins.readFile "/run/secrets/docker/fireflyiii_db_name";
  fireflyiii_db_user = builtins.readFile "/run/secrets/docker/fireflyiii_db_user";
  fireflyiii_db_password = builtins.readFile "/run/secrets/docker/fireflyiii_db_password";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      fireflyiii = {
        image = "fireflyiii/core:${service-version}";
        environment = {
          DB_CONNECTION = "sqlite";
          APP_KEY = "${fireflyiii_app_key}";
          APP_URL = "https://fireflyiii.hemvist.duckdns.org";
          TRUSTED_PROXIES = "**";
          # DB_HOST = "fireflyiii_db";
          # DB_PORT = "3306";
          # DB_DATABASE = "${fireflyiii_db_name}";
          # DB_USERNAME = "${fireflyiii_db_user}";
          # DB_PASSWORD = "${fireflyiii_db_password}";
        };
        ports = [
          "${service-port}:8080"
        ];
        volumes = [
          "${docker-data}/${service-name}:/var/www/html/storage/database"
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
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=8080"
        ];
        # dependsOn = [ "fireflyiii_db" ];
      };

      # fireflyiii_db = {
      #   image = "mariadb:10.7.3"; # renovate: datasource=docker depName=mariadb
      #   environment = {
      #     MYSQL_RANDOM_ROOT_PASSWORD = "yes";
      #     MYSQL_USER = "${fireflyiii_db_user}";
      #     MYSQL_PASSWORD = "${fireflyiii_db_password}";
      #   };
      #   volumes = [
      #     "${docker-data}/${service-name}/database:/var/lib/mysql"
      #   ];
      #   extraOptions = [
      #     "--network=web"
      #     # TODO healthcheck buggy?
      #     # "--health-cmd='pg_isready -U miniflux'"
      #     "--health-interval=10s"
      #   ];
      # };
    };
  };
}
