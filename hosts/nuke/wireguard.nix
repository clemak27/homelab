{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.6.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/run/secrets/wg/private_key";
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
          publicKey = builtins.readFile "${config.sops.secrets."wg/enchilada/public_key".path}";
          presharedKeyFile = "/run/secrets/wg/enchilada/pre_shared_key";
          allowedIPs = [ "10.6.0.2/32" ];
        }
        {
          # argentum
          publicKey = builtins.readFile "${config.sops.secrets."wg/argentum/public_key".path}";
          presharedKeyFile = "/run/secrets/wg/argentum/pre_shared_key";
          allowedIPs = [ "10.6.0.3/32" ];
        }
        {
          # silfur
          publicKey = builtins.readFile "${config.sops.secrets."wg/silfur/public_key".path}";
          presharedKeyFile = "/run/secrets/wg/silfur/pre_shared_key";
          allowedIPs = [ "10.6.0.4/32" ];
        }
        {
          # deck
          publicKey = builtins.readFile "${config.sops.secrets."wg/deck/public_key".path}";
          presharedKeyFile = "/run/secrets/wg/deck/pre_shared_key";
          allowedIPs = [ "10.6.0.5/32" ];
        }
      ];
    };
  };
}
