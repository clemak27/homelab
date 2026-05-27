{ ... }: {
  hardware.rpi4 = {
    nixos =
      { lib, ... }:
      {
        boot = {
          loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
          };
          zfs.forceImportRoot = false;
        };

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
