{ pkgs, config, ... }:
{
  networking.firewall.enable = false;

  services.k3s = {
    enable = true;
    role = "agent";
    # TODO pin to 1.27 once available
    package = (pkgs.k3s.overrideAttrs (old: { buildInputs = old.buildInputs or [ ] ++ [ pkgs.cryptsetup ]; }));
    tokenFile = config.sops.secrets."k3s_agent_token".path;
    serverAddr = "https://192.168.178.100:6443";
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

  boot.kernelParams = [
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = "1048576";
    "fs.inotify.max_user_watches" = "1048576"; # 128 times the default 8192
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
}
