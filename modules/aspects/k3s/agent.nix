{ den, ... }: {
  k3s.agent = {
    includes = [
      den.aspects.sops
    ];

    nixos =
      { pkgs, config, ... }:
      {
        networking.firewall.enable = false;

        services.k3s = {
          enable = true;
          role = "agent";
          # sudo cat /var/lib/rancher/k3s/server/agent-token
          # token = "verysecretsecret";
          tokenFile = config.sops.secrets."k3s_agent_token".path;
          serverAddr = "https://192.168.178.100:6443";
          nodeLabel = [
            "node-role.kubernetes.io/worker=true"
          ];
          # nodeTaint = "ha";
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

        # ???
        # boot.kernelParams = [
        #   "cgroup_memory=1"
        #   "cgroup_enable=memory"
        # ];

      };
  };
}
