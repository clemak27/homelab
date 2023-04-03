{ config, pkgs, ... }:
{
  # networking.networkmanager.dns = "dnsmasq";

  services.dnsmasq = {
    enable = true;
    settings = {
      # user = "dnsmasq";
      # group = "dnsmasq";
      # bind-dynamic;
      # interface = "enp3s0,wg0";
      listen-address = "::1,127.0.0.1,192.168.178.100";
      # conf-dir = "/etc/dnsmasq.d";
      addn-hosts = "/etc/hosts.d/homelab,/etc/hosts.d/someonewhocares";
      server = [
        "1.1.1.1"
      ];
    };
  };

  # environment.etc = {
  #   "NetworkManager/dnsmasq.d/config".text = ''
  #     user=dnsmasq
  #     group=dnsmasq
  #     bind-dynamic
  #     interface=enp3s0,wg0
  #     server=1.1.1.1
  #     listen-address=::1,127.0.0.1,192.168.178.100
  #     conf-dir=/etc/dnsmasq.d
  #     addn-hosts=/etc/hosts.d/homelab,/etc/hosts.d/someonewhocares
  #   '';
  # };

  environment.etc = {
    "hosts.d/homelab".text = ''
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
      192.168.178.100 qobuz-dl.wallstreet30.cc
      192.168.178.100 radarr.wallstreet30.cc
      192.168.178.100 recipes.wallstreet30.cc
      192.168.178.100 registry.wallstreet30.cc
      192.168.178.100 sonarr.wallstreet30.cc
      192.168.178.100 syncthing.wallstreet30.cc
      192.168.178.100 traefik.wallstreet30.cc
      192.168.178.100 transmission.wallstreet30.cc
      192.168.178.100 vaultwarden.wallstreet30.cc
    '';

    # TODO use flake
    # "hosts.d/someonewhocares".source = pkgs.fetchurl {
    #   url = "https://someonewhocares.org/hosts/hosts";
    #   hash = "sha256-xDldHtC7KtDMxgLGaNmBoPB89WwZMWt4uYrN6XMWmU4=";
    # };
  };

}
