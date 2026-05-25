{ den, ... }: {
  k3s.agent = {
    includes = [
      den.aspects.sops
    ];

    nixos =
      { pkgs, config, ... }:
      {
        sops.secrets."k3s_agent_token" = { };

        networking.firewall.enable = false;

        services.k3s = {
          enable = true;
          role = "agent";
          tokenFile = config.sops.secrets."k3s_agent_token".path;
          serverAddr = "https://192.168.178.100:6443";
          # nodeLabel = [ "node-role.kubernetes.io/worker=true" ];
          nodeTaint = [ "node-type=agent:NoSchedule" ];
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

        systemd.tmpfiles.rules = [
          "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
        ];
      };
  };
}
