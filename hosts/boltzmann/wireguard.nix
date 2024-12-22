{ config, pkgs, ... }:
{
  # Enable NAT
  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = [ "wg0" ];
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.6.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "${config.sops.secrets."wg/private_key".path}";
      mtu = 1420;
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp3s0 -j MASQUERADE -s 10.6.0.1/24
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp3s0 -j MASQUERADE -s 10.6.0.1/24
      '';
      peers = [
        {
          # planck
          publicKey = "kM5NBf1dpdRxV7X6dtPJ2RCYmScN2Z9eadiSNRcIyQ4=";
          presharedKeyFile = "${config.sops.secrets."wg/planck/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.2/32" ];
        }
        {
          # newton
          publicKey = "SidO/Rk16lghr6awbSGdp0AIh/hC429XuVu2d7EzFHk=";
          presharedKeyFile = "${config.sops.secrets."wg/newton/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.4/32" ];
        }
        {
          # fermi
          publicKey = "m/I4FN9oYtJFS5NPTT+VjHnCEy0uSBIG6Pg1JvjF23g=";
          presharedKeyFile = "${config.sops.secrets."wg/fermi/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.5/32" ];
        }
        {
          # w2h
          publicKey = "GNunYJIjSQ5BPPRkRcODQQFl+Ev4BzAdtQGeKDZh9Sw=";
          presharedKeyFile = "${config.sops.secrets."wg/w2h/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.6/32" ];
        }
        {
          # lagrange
          publicKey = "zrK/VO0osxj4/cq8rzj8nFvP9N4q6Aox/NjMWWZ3ER8=";
          presharedKeyFile = "${config.sops.secrets."wg/lagrange/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.7/32" ];
        }
      ];
    };
  };
}
