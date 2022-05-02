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
        ports = [
          "443:443"
          "8007:8007"
          "8883:8883"
          "5223:5223"
        ];
        environment = {
          BUMPER_ANNOUNCE_IP = "192.168.178.101";
        };
        volumes = [
          "${docker-data}/${service-name}/data:/bumper/data"
          "${docker-data}/${service-name}/certs:/bumper/certs"
          "${docker-data}/${service-name}/logs:/bumper/logs"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
