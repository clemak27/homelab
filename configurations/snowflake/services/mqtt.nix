{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "mqtt";
  service-version = "2.0.14"; # renovate: datasource=docker depName=eclipse-mosquitto
  service-port = "8080";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      mqtt =
        {
          image = "eclipse-mosquitto:${service-version}";
          volumes = [
            "${docker-data}/${service-name}/config:/mosquitto/config"
            "${docker-data}/${service-name}/data:/mosquitto/data"
            "${docker-data}/${service-name}/log:/mosquitto/log"
          ];
          ports = [
            "1883:1883"
            "9001:9001"
          ];
          extraOptions = [
            "--network=web"
          ];
        };
    };
    networking.extraHosts = ''
      192.168.178.100 mqtt.${config.servercfg.domain}	
    '';
  };
}
