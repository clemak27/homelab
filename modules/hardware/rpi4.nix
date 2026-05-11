{ inputs, ... }: {
  flake-file.inputs.nixos-hardware = {
    url = "github:NixOS/nixos-hardware/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  hardware.rpi4 = {
    nixos =
      { lib, ... }:
      {
        imports = [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
        ];

        # evaluation warning: `boot.zfs.forceImportRoot` is using the default value of `true`.
        # It is highly recommended to set it to `false`, the new default from 26.11 on,
        # to reduce the risk of data loss. Alternatively, you can silence this warning by explicitly setting it to `true`.
        boot.zfs.forceImportRoot = false;

        networking = {
          firewall.enable = false;
          networkmanager.enable = true;
          useDHCP = lib.mkDefault true;
        };

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
          };
        };

        swapDevices = [{ device = "/swapfile"; size = 2048; }];
      };
  };
}
