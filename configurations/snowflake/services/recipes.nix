{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "recipes";
  service-version = "1.3.3"; # renovate: datasource=docker depName=vabene1111/recipes
  service-port = "8088";
  internal-port = "8080";

  recipes_secret_key = builtins.readFile "${config.sops.secrets."docker/recipes_secret_key".path}";
  recipes_db_user = builtins.readFile "${config.sops.secrets."docker/recipes_db_user".path}";
  recipes_db_password = builtins.readFile "${config.sops.secrets."docker/recipes_db_password".path}";
  recipes_db_name = builtins.readFile "${config.sops.secrets."docker/recipes_db_name".path}";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      recipes = {
        image = "vabene1111/recipes:${service-version}";
        environment = {
          SECRET_KEY = "${recipes_secret_key}";
          DB_ENGINE = "django.db.backends.postgresql";
          POSTGRES_HOST = "recipes_db";
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "${recipes_db_user}";
          POSTGRES_PASSWORD = "${recipes_db_password}";
          POSTGRES_DB = "${recipes_db_name}";
        };
        ports = [
          "${service-port}:${internal-port}"
        ];
        volumes = [
          "${docker-data}/${service-name}/staticfiles:/opt/recipes/staticfiles"
          "${docker-data}/${service-name}/mediafiles:/opt/recipes/mediafiles"
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
        dependsOn = [ "recipes_db" ];
      };

      recipes_db = {
        image = "postgres:13.6"; # renovate: datasource=docker depName=postgres
        environment = {
          POSTGRES_USER = "${recipes_db_user}";
          POSTGRES_PASSWORD = "${recipes_db_password}";
          POSTGRES_DB = "${recipes_db_name}";
        };
        volumes = [
          "${docker-data}/${service-name}_db:/var/lib/postgresql/data"
        ];
        extraOptions = [
          "--network=web"
          "--health-cmd=pg_isready -U ${recipes_db_user} -d ${recipes_db_name}"
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
