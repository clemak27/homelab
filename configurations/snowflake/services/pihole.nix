{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data/docker";

  service-name = "pihole";
  service-version = "2022.01.1"; # renovate: datasource=docker depName=pihole/pihole
  service-port = "8456";
  exporter-version = "v0.3.0";
  pihole_pw = builtins.readFile "/run/secrets/docker/pihole_pw";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      pihole = {
        image = "pihole/pihole:${service-version}";
        environment = {
          TZ = "Europe/Vienna";
          WEBPASSWORD = "${pihole_pw}";
        };
        ports = [
          "${service-port}:${service-port}"
          "53:53/tcp"
          "53:53/udp"
          "67:67/udp"
        ];
        volumes = [
          "${docker-data}/${service-name}/etc-pihole/:/etc/pihole/"
          "${docker-data}/${service-name}/etc-dnsmasq.d/:/etc/dnsmasq.d/"
          "${docker-data}/${service-name}/lighttpd.external.conf:/etc/lighttpd/external.conf"
        ];
        extraOptions = [
          "--network=web"
          "--cap-add=NET_ADMIN"
          "--label=traefik.enable=true"
          "--label=traefik.http.routers.${service-name}-router.entrypoints=https"
          "--label=traefik.http.routers.${service-name}-router.rule=Host(`${service-name}.hemvist.duckdns.org`)"
          "--label=traefik.http.routers.${service-name}-router.tls=true"
          "--label=traefik.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
          # HTTP Services
          "--label=traefik.http.routers.${service-name}-router.service=${service-name}-service"
          "--label=traefik.http.services.${service-name}-service.loadbalancer.server.port=${service-port}"
        ];
      };
      pihole-exporter = {
        image = "ekofr/pihole-exporter:${exporter-version}";
        environment = {
          PIHOLE_HOSTNAME = "192.168.0.30";
          PIHOLE_PASSWORD = "${pihole_pw}";
          PIHOLE_PORT = "${service-port}";
          PORT = "9617";
        };
        ports = [
          "9617:9617"
        ];
        extraOptions = [
          "--network=web"
        ];
      };
    };
  };
}
