{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data/docker";

  service-name = "pihole";
  service-version = "2022.04.2beta"; # renovate: datasource=docker depName=pihole/pihole
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
        volumes = [
          "${docker-data}/${service-name}/etc-pihole/:/etc/pihole/"
          "${docker-data}/${service-name}/etc-dnsmasq.d/:/etc/dnsmasq.d/"
          "${docker-data}/${service-name}/lighttpd.external.conf:/etc/lighttpd/external.conf"
        ];
        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN"
        ];
      };
      pihole-exporter = {
        image = "ekofr/pihole-exporter:${exporter-version}";
        environment = {
          PIHOLE_HOSTNAME = "192.168.178.100";
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
