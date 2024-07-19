{ pkgs, lib, ... }:
{
  networking.firewall.enable = false;

  services.k3s = {
    enable = true;
    role = "server";
    package = (pkgs.k3s.overrideAttrs (old: { buildInputs = old.buildInputs or [ ] ++ [ pkgs.cryptsetup ]; }));
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2020-08.org.linux-iscsi.initiatorhost:longhorn";
  };

  virtualisation.docker = {
    enable = true;
  };

  users.users.clemens = {
    extraGroups = [ "docker" ];
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = "1048576";
    "fs.inotify.max_user_watches" = "1048576"; # 128 times the default 8192
  };

  environment.etc = {
    "rancher/k3s/config.yaml".text = ''
      write-kubeconfig-mode: "0644"
      disable: local-storage
      tls-san:
        - "k3s.wallstreet30.cc"
    '';

    "rancher/k3s/registries.yaml".text = ''
      mirrors:
        "registry.wallstreet30.cc":
          endpoint:
            - "https://registry.wallstreet30.cc"
    '';
  };

  system.activationScripts.makeK3sTraefikConfig = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/rancher/k3s/server/manifests

    cat << 'EOF' > /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
      name: traefik
      namespace: kube-system
    spec:
      valuesContent: |-
        ports:
          gitea-ssh:
            port: 222
            expose: true
        globalArguments:
          - "--global.sendanonymoususage=false"
          - "--api.insecure=true"
    EOF
  '';

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
}
