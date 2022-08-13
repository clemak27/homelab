{ config, lib, pkgs, ... }:
let
  docker-data = "${config.servercfg.data_dir}";

  service-name = "traefik";
  service-version = "v2.8.3"; # renovate: datasource=docker depName=traefik

  cloudflare_api_key = builtins.readFile "${config.sops.secrets."cloudflare_api_key".path}";
in
{
  config = {
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:${service-version}";
        environment = {
          CLOUDFLARE_EMAIL = "clemak27@mailbox.org";
          CLOUDFLARE_DNS_API_TOKEN = "${cloudflare_api_key}";
        };
        ports = [
          "80:80"
          "443:443"
          "8080:8080"
          "222:222"
        ];
        volumes = [
          "/etc/timezone:/etc/timezone:ro"
          "/etc/localtime:/etc/localtime:ro"
          "/var/run/docker.sock:/var/run/docker.sock"
          "${docker-data}/${service-name}/traefik.log:/traefik.log"
          "${docker-data}/${service-name}/acme.json:/acme.json"
        ];
        cmd = [
          "--api.insecure=true"
          "--api.dashboard=true"
          "--api.debug=true"
          "--log.level=INFO"
          "--log.filePath=/traefik.log"
          "--providers.docker=true"
          "--providers.docker.exposedbydefault=false"
          "--providers.docker.network=web"
          "--entryPoints.http.address=:80"
          "--entryPoints.https.address=:443"
          "--entryPoints.ssh.address=:222"
          "--certificatesResolvers.letsEncrypt.acme.email=clemak27@mailbox.org"
          "--certificatesResolvers.letsEncrypt.acme.storage=/acme.json"
          "--certificatesResolvers.letsEncrypt.acme.dnsChallenge.provider=cloudflare"
        ];
        extraOptions = [
          "--network=web"
          "--ip=172.19.0.19"
          "--label=traefik.enable=true"
          # HTTP-to-HTTPS Redirect
          "--label=${service-name}.http.routers.http-catchall.entrypoints=http"
          "--label=${service-name}.http.routers.http-catchall.rule=HostRegexp(`{host:.+}`)"
          "--label=${service-name}.http.routers.http-catchall.middlewares=redirect-to-https"
          "--label=${service-name}.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
          # HTTP Routers
          "--label=${service-name}.http.routers.${service-name}-router.entrypoints=https"
          "--label=${service-name}.http.routers.${service-name}-router.rule=Host(`${service-name}.${config.servercfg.domain}`)"
          "--label=${service-name}.http.routers.${service-name}-router.tls=true"
          "--label=${service-name}.http.routers.${service-name}-router.tls.certresolver=letsEncrypt"
          "--label=${service-name}.http.routers.${service-name}-router.service=api@internal"
          "--label=${service-name}.http.routers.${service-name}-router.tls.domains[0].main=${config.servercfg.domain}"
          "--label=${service-name}.http.routers.${service-name}-router.tls.domains[0].sans=*.${config.servercfg.domain}"
        ];
      };
    };

    networking.extraHosts = ''
      192.168.178.100 ${service-name}.${config.servercfg.domain}
    '';
  };
}








