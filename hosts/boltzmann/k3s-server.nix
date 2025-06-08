{ ... }:
{
  networking.firewall.enable = false;

  services.k3s = {
    enable = true;
    role = "server";
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:longhorn";
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = "1048576";
    "fs.inotify.max_user_watches" = "1048576";
  };

  environment.etc = {
    "rancher/k3s/config.yaml".text = ''
      write-kubeconfig-mode: "0644"
      disable: local-storage,traefik
      tls-san:
        - "k3s.wallstreet30.cc"
    '';
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
}
