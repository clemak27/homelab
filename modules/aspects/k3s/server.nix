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
            disable: local-storage
            tls-san:
              - "k3s.wallstreet30.cc"
            write-kubeconfig-mode: "0644"
          '';
        };

        systemd.tmpfiles.rules = [
          "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
        ];

        system.activationScripts.traefikConfig = lib.stringAfter [ "var" ] ''
          cat << EOF > /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
          apiVersion: helm.cattle.io/v1
          kind: HelmChartConfig
          metadata:
            name: traefik
            namespace: kube-system
          spec:
            valuesContent: |-
              globalArguments:
                - "--global.sendanonymoususage=false"
                - "--api.insecure=true"
              additionalArguments:
                - "--entryPoints.web.transport.respondingTimeouts.readTimeout=300s"
                - "--entryPoints.web.transport.respondingTimeouts.writeTimeout=300s"
                - "--entryPoints.web.transport.respondingTimeouts.idleTimeout=300s"
                - "--entryPoints.websecure.transport.respondingTimeouts.readTimeout=300s"
                - "--entryPoints.websecure.transport.respondingTimeouts.writeTimeout=300s"
                - "--entryPoints.websecure.transport.respondingTimeouts.idleTimeout=300s"
          EOF
        '';
      };
  };
}
