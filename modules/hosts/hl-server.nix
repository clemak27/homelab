{ inputs, den, hardware, k3s, ... }: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.hl-server = {
    includes = [
      hardware.amd64

      k3s.server

      den.aspects.blocky
      den.aspects.wireguard
    ];

    nixos =
      {
        imports = [
          inputs.disko.nixosModules.disko
        ];

        networking.hostName = "hl-server";

        disko.devices = {
          disk = {
            main = {
              device = "/dev/nvme0n1";
              type = "disk";
              content = {
                type = "gpt";
                partitions = {
                  ESP = {
                    size = "512M";
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [ "umask=0077" ];
                    };
                  };
                  root = {
                    name = "root";
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "xfs";
                      mountpoint = "/";
                    };
                  };
                };
              };
            };
          };
        };

        fileSystems = {
          # mc-01
          "/var/mnt/media" = {
            device = "/dev/disk/by-uuid/b2c20ad4-3a1a-4656-abea-d9f774170726";
            fsType = "btrfs";
            options = [ "subvol=media" ];
          };

          # mc-02
          "/var/mnt/backups" = {
            device = "/dev/disk/by-uuid/6f4c22d1-60c8-4f91-a2b4-c04f30b77f45";
            fsType = "btrfs";
            options = [ "subvol=backups" ];
          };
          "/var/mnt/series" = {
            device = "/dev/disk/by-uuid/6f4c22d1-60c8-4f91-a2b4-c04f30b77f45";
            fsType = "btrfs";
            options = [ "subvol=series" ];
          };

          # mc-03
          "/var/mnt/media2" = {
            device = "/dev/disk/by-uuid/404897a7-c2df-406e-a6e7-8b914259a2fe";
            fsType = "btrfs";
          };
        };

        # media bind-mounts
        fileSystems."/var/mnt/media/series" = {
          device = "/var/mnt/media2/series";
          options = [ "bind" ];
        };
        fileSystems."/var/mnt/media/movies" = {
          device = "/var/mnt/media2/movies";
          options = [ "bind" ];
        };

        # nfs
        fileSystems."/var/nfs/media" = {
          device = "/var/mnt/media";
          options = [ "bind" ];
        };
        fileSystems."/var/nfs/backups" = {
          device = "/var/mnt/backups";
          options = [ "bind" ];
        };
        fileSystems."/var/nfs/series" = {
          device = "/var/mnt/series";
          options = [ "bind" ];
        };

        services.nfs.server = {
          enable = true;
          exports = ''
            /var/nfs                *(rw,fsid=0,no_subtree_check)
            /var/nfs/media          *(rw,nohide,insecure,no_subtree_check,crossmnt)
            /var/nfs/backups        *(rw,no_root_squash,sync)
            /var/nfs/series         *(rw,nohide,insecure,no_subtree_check)
          '';
        };
      };
  };
}
