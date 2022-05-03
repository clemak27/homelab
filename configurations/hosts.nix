{ config, pkgs, lib, ... }:
{
  networking.extraHosts =
    ''
      192.168.178.100 calibre.hemvist.duckdns.org
      192.168.178.100 deemix.hemvist.duckdns.org	
      192.168.178.100 fireflyiii.hemvist.duckdns.org	
      192.168.178.100 gitea.hemvist.duckdns.org	
      192.168.178.100 grafana.hemvist.duckdns.org	
      192.168.178.100 homer.hemvist.duckdns.org	
      192.168.178.100 jackett.hemvist.duckdns.org	
      192.168.178.100 jellyfin.hemvist.duckdns.org
      192.168.178.100 lidarr.hemvist.duckdns.org
      192.168.178.100 miniflux.hemvist.duckdns.org	
      192.168.178.100 navidrome.hemvist.duckdns.org	
      192.168.178.100 pihole.hemvist.duckdns.org	
      192.168.178.100 plex.hemvist.duckdns.org	
      192.168.178.100 prometheus.hemvist.duckdns.org	
      192.168.178.100 radarr.hemvist.duckdns.org
      192.168.178.100 recipes.hemvist.duckdns.org
      192.168.178.100 sonarr.hemvist.duckdns.org	
      192.168.178.100 syncthing.hemvist.duckdns.org
      192.168.178.100 traefik.hemvist.duckdns.org
      192.168.178.100 transmission.hemvist.duckdns.org
      192.168.178.100 vaultwarden.hemvist.duckdns.org

      192.168.178.101 ecouser.net
      192.168.178.101 ecovacs.com
      192.168.178.101 ecovacs.net
    '';
}
