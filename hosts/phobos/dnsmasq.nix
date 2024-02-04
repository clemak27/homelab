let
  dnsIP = "192.168.178.102";
  lbIP = "192.168.178.169";
in
{
  networking.firewall.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "end0,wg0";
      listen-address = "::1,127.0.0.1,${dnsIP}";
      server = [
        "1.1.1.1"
      ];
    };
  };

  networking.extraHosts = ''
    192.168.178.169 theia
    192.168.178.101 deimos
    192.168.178.102 phobos

    ${lbIP} argocd.wallstreet30.cc
    ${lbIP} longhorn.wallstreet30.cc
    ${lbIP} registry.wallstreet30.cc
    ${lbIP} traefik.wallstreet30.cc

    ${lbIP} calibre.wallstreet30.cc
    ${lbIP} filebrowser.wallstreet30.cc
    ${lbIP} gitea.wallstreet30.cc
    ${lbIP} home-assistant.wallstreet30.cc
    ${lbIP} jackett.wallstreet30.cc
    ${lbIP} jellyfin.wallstreet30.cc
    ${lbIP} miniflux.wallstreet30.cc
    ${lbIP} qobuz-dl.wallstreet30.cc
    ${lbIP} radarr.wallstreet30.cc
    ${lbIP} readarr.wallstreet30.cc
    ${lbIP} recipes.wallstreet30.cc
    ${lbIP} sonarr.wallstreet30.cc
    ${lbIP} syncthing.wallstreet30.cc
    ${lbIP} transmission.wallstreet30.cc
    ${lbIP} vaultwarden.wallstreet30.cc
    ${lbIP} zigbee2mqtt.wallstreet30.cc

    ${lbIP} grafana.wallstreet30.cc
    ${lbIP} prometheus.wallstreet30.cc
  '';
}
