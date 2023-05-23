{ config, pkgs, ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "enp3s0,wg0";
      listen-address = "::1,127.0.0.1,192.168.178.100";
      server = [
        "1.1.1.1"
      ];
    };
  };

  networking.extraHosts = ''
    192.168.178.100 argocd.wallstreet30.cc
    192.168.178.100 deconz.wallstreet30.cc
    192.168.178.100 filebrowser.wallstreet30.cc
    192.168.178.100 gitea.wallstreet30.cc
    192.168.178.100 home-assistant.wallstreet30.cc
    192.168.178.100 jackett.wallstreet30.cc
    192.168.178.100 jellyfin.wallstreet30.cc
    192.168.178.100 k3d.wallstreet30.cc
    192.168.178.100 longhorn.wallstreet30.cc
    192.168.178.100 miniflux.wallstreet30.cc
    192.168.178.100 prometheus.wallstreet30.cc
    192.168.178.100 qobuz-dl.wallstreet30.cc
    192.168.178.100 radarr.wallstreet30.cc
    192.168.178.100 recipes.wallstreet30.cc
    192.168.178.100 registry.wallstreet30.cc
    192.168.178.100 sonarr.wallstreet30.cc
    192.168.178.100 syncthing.wallstreet30.cc
    192.168.178.100 traefik.wallstreet30.cc
    192.168.178.100 transmission.wallstreet30.cc
    192.168.178.100 vaultwarden.wallstreet30.cc
    192.168.178.100 zigbee2mqtt.wallstreet30.cc
  '';
}
