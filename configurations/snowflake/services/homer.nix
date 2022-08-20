{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "homer";
  service-version = "21.09.2"; # renovate: datasource=docker depName=b4bz/homer
  service-port = "8085";
  internal-port = "8080";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      homer = {
        image = "b4bz/homer:${service-version}";
        ports = [
          "${service-port}:${internal-port}"
        ];
        environment = {
          UID = "1000";
          GID = "1000";
        };
        volumes = [
          "${docker-data}/homer:/www/assets"
          "/etc/homer-config.json:/www/assets/config-local.yml:ro"
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
      };
    };

    networking.extraHosts = ''
      192.168.178.100 ${service-name}.${config.servercfg.domain}
    '';
    environment.etc."homer-config.json" = {
      uid = 1000;
      gid = 1000;
      mode = "644";
      text = ''
        links:
          - name: "proper urls"
            icon = "fas fa-file-alt"
            url = "#config"
      '';
      # text = builtins.toJSON ({
      #   links = [
      #     name = "proper urls"
      #     icon = "fas fa-file-alt"
      #     url = "#config"
      #   ];
      # });
    };
  };
}
