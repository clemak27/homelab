{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "gitea";
  service-version = "1.17.2"; # renovate: datasource=docker depName=gitea/gitea
  service-port = "3000";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      gitea = {
        image = "gitea/gitea:${service-version}";
        ports = [
          "${service-port}:${service-port}"
        ];
        volumes = [
          "${docker-data}/${service-name}:/data"
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        log-driver = "loki";
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
          # SSH access
          "--label=traefik.tcp.routers.gitea-ssh.rule=HostSNI(`*`)"
          "--label=traefik.tcp.routers.gitea-ssh.entrypoints=ssh"
          "--label=traefik.tcp.routers.gitea-ssh.service=gitea-ssh-service"
          "--label=traefik.tcp.services.gitea-ssh-service.loadbalancer.server.port=22"
          # loki-logging
          "--log-opt=loki-url=http://192.168.178.100:3100/loki/api/v1/push"
          "--log-opt=loki-external-labels=job=${service-name}"
        ];
      };
    };

    networking.extraHosts = ''
      192.168.178.100 ${service-name}.${config.servercfg.domain}
    '';
  };
}
