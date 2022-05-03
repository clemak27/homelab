{ config, lib, pkgs, ... }:
let
  docker-data = "/home/clemens/data/docker";

  service-name = "bumper";
  service-version = "latest";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      bumper = {
        image = "bmartin5692/bumper:${service-version}";
        environment = {
          BUMPER_ANNOUNCE_IP = "192.168.178.101";
          BUMPER_LISTEN = "0.0.0.0";
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Rome";
          LOG_TO_STDOUT = "true";
          # BUMPER_DEBUG = "true";
        };
        volumes = [
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
          "${docker-data}/${service-name}/data:/bumper/data"
          "${docker-data}/${service-name}/certs:/bumper/certs"
          "${docker-data}/${service-name}/logs:/bumper/logs"
        ];
        extraOptions = [
          "--network=bumper"
        ];
      };
      ngnix = {
        image = "nginx:alpine";
        ports = [
          "443:443"
          "8007:8007"
          "8883:8883"
          "5223:5223"
        ];
        volumes = [
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
          "${docker-data}/nginx:/etc/nginx:ro"
        ];
        extraOptions = [
          "--network=bumper"
        ];
        dependsOn = [ "bumper" ];
      };
    };
  };
}
