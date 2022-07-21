{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data/docker";

  service-name = "deconz";
  service-version = "2.16.01"; # renovate: datasource=docker depName=deconzcommunity/deconz
in
{
  config = {
    virtualisation.oci-containers.containers = {
      deconz = {
        image = "deconzcommunity/deconz:${service-version}";
        environment = {
          TZ = "Europe/Rome";
          DECONZ_WEB_PORT = "8082";
          DECONZ_WS_PORT = "8443";
        };
        ports = [
          "8082:8082"
          "8443:8443"
        ];
        volumes = [
          # "/etc/timezone:/etc/timezone:ro"
          # "/etc/localtime:/etc/localtime:ro"
          "${docker-data}/${service-name}:/opt/deCONZ"
        ];
        extraOptions = [
          "--device=/dev/ttyACM0"
        ];
      };
    };
  };
}
