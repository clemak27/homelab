{ ... }: {
  k3s.server = {
    nixos =
      { pkgs, lib, ... }:
      {
        networking.firewall.enable = false;

        services.k3s = {
          enable = true;
          role = "server";
          gracefulNodeShutdown = {
            enable = true;
            shutdownGracePeriod = "1m";
            shutdownGracePeriodCriticalPods = "30s";
          };
        };

        environment.systemPackages = with pkgs; [
          cryptsetup
          nfs-utils
        ];

        services.openiscsi = {
          enable = true;
          name = "iqn.2020-08.org.linux-iscsi.initiatorhost:longhorn";
        };
        systemd.services.iscsid.serviceConfig = {
          PrivateMounts = "yes";
          BindPaths = "/run/current-system/sw/bin:/bin";
        };

        boot.kernel.sysctl = {
          "fs.inotify.max_user_instances" = "1048576";
          "fs.inotify.max_user_watches" = "1048576";
        };

        environment.etc = {
          "rancher/k3s/config.yaml".text = ''
            disable: local-storage,servicelb
            tls-san:
              - "k3s.wallstreet30.cc"
            write-kubeconfig-mode: "0644"
          '';
        };

        systemd.tmpfiles.rules = [
          "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
        ];
      };
  };
}
