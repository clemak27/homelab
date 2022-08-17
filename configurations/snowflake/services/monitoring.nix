{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      prometheus =
        let
          service-name = "prometheus";
          service-version = "v2.37.0"; # renovate: datasource=docker depName=prom/prometheus
          service-port = "9090";
        in
        {
          image = "prom/prometheus:${service-version}";
          volumes = [
            "${docker-data}/${service-name}/config:/config"
            "${docker-data}/${service-name}/data:/prometheus"
          ];
          ports = [
            "${service-port}:${service-port}"
          ];
          cmd = [
            "--config.file=/config/config.yml"
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

      cadvisor =
        let
          service-name = "cadvisor";
          service-version = "v0.45.0"; # renovate: datasource=docker depName=gcr.io/cadvisor/cadvisor
          service-port = "8080";
        in
        {
          image = "gcr.io/cadvisor/cadvisor:${service-version}";
          volumes = [
            "/:/rootfs:ro"
            "/var/run:/var/run:rw"
            "/sys:/sys:ro"
            "/var/lib/docker/:/var/lib/docker:ro"
          ];
          ports = [
            "8083:${service-port}"
          ];
          extraOptions = [
            "--network=web"
          ];
        };

      grafana =
        let
          service-name = "grafana";
          service-version = "9.1.0"; # renovate: datasource=docker depName=grafana/grafana
          service-port = "3001";
        in
        {
          image = "grafana/grafana:${service-version}";
          volumes = [
            "${docker-data}/${service-name}:/var/lib/grafana"
          ];
          ports = [
            "${service-port}:3000"
          ];
          user = "1000";
          extraOptions = [
            "--network=web"
            "--label=traefik.enable=true"
            "--label=traefik.http.routers.${service-name}-router.entrypoints=https"
            "--label=traefik.http.routers.${service-name}-router.rule=Host(`${service-name}.${config.servercfg.domain}`)"
            "--label=traefik.http.routers.${service-name}-router.tls=true"
            "--label=traefik.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
            # HTTP Services
            "--label=traefik.http.routers.${service-name}-router.service=${service-name}-service"
            "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=3000"
          ];
        };

      loki =
        let
          service-name = "loki";
          service-version = "2.6.0"; # renovate: datasource=docker depName=grafana/loki
          service-port = "3100";
        in
        {
          image = "grafana/loki:${service-version}";
          volumes = [
            "${docker-data}/${service-name}:/etc/loki"
          ];
          ports = [
            "${service-port}:${service-port}"
          ];
          cmd = [
            "-config.file=/etc/loki/config.yaml"
          ];
          extraOptions = [
            "--network=web"
          ];
        };
    };

    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
      disabledCollectors = [
        "textfile"
      ];
      openFirewall = true;
      firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
    };


    networking.extraHosts = ''
      192.168.178.100 prometheus.${config.servercfg.domain}	
      192.168.178.100 grafana.${config.servercfg.domain}	
    '';
  };
}
