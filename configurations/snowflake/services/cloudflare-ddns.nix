{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "cloudflare-ddns";
  service-version = "latest";

  cloudflare_api_key = builtins.readFile "/run/secrets/cloudflare_api_key";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      cloudflare-ddns = {
        image = "oznu/cloudflare-ddns:${service-version}";
        environment = {
          API_KEY="${cloudflare_api_key}";
          ZONE="${config.servercfg.domain}";
        };
      };
    };
  };
}








