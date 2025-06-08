{
  imports = [
    ./general.nix
    ./zsh.nix

    ./disko.nix
    ./hardware-configuration.nix
    ./hdds.nix

    ./dnsmasq.nix
    ./k3s-server.nix
    ./sops.nix
    ./wireguard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "boltzmann";

  system.stateVersion = "25.05";
}
