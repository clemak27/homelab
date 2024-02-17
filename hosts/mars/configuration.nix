{
  imports = [
    ./hardware-configuration.nix

    ./discs.nix
    ./dnsmasq.nix
    ./k3s-server.nix
    ./sops.nix
    ./wireguard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "mars";

  system.stateVersion = "23.11";
}
