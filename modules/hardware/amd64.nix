{ ... }: {
  hardware.amd64 = {
    nixos =
      { modulesPath, lib, config, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [ "dm-snapshot" ];
        boot.kernelModules = [ "kvm-amd" ];
        boot.extraModulePackages = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        networking = {
          firewall.enable = false;
          networkmanager.enable = true;
          useDHCP = lib.mkDefault true;
        };

        boot.loader = {
          systemd-boot.enable = true;
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
        };
      };
  };
}
