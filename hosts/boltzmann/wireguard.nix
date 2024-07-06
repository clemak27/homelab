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
          # enchilada
          publicKey = "kM5NBf1dpdRxV7X6dtPJ2RCYmScN2Z9eadiSNRcIyQ4=";
          presharedKeyFile = "${config.sops.secrets."wg/enchilada/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.2/32" ];
        }
        {
          # silfur
          publicKey = "SidO/Rk16lghr6awbSGdp0AIh/hC429XuVu2d7EzFHk=";
          presharedKeyFile = "${config.sops.secrets."wg/silfur/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.4/32" ];
        }
        {
          # deck
          publicKey = "m/I4FN9oYtJFS5NPTT+VjHnCEy0uSBIG6Pg1JvjF23g=";
          presharedKeyFile = "${config.sops.secrets."wg/deck/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.5/32" ];
        }
        {
          # w2h
          publicKey = "GNunYJIjSQ5BPPRkRcODQQFl+Ev4BzAdtQGeKDZh9Sw=";
          presharedKeyFile = "${config.sops.secrets."wg/w2h/pre_shared_key".path}";
          allowedIPs = [ "10.6.0.6/32" ];
        }
      ];
    };
  };
}
