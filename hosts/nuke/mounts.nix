{ config, pkgs, ... }:
{
  # uranium-235
  fileSystems."/var/mnt/archive" = {
    device = "/dev/disk/by-uuid/6f6e045e-8a0c-4bdf-9be0-89697d208865";
    fsType = "btrfs";
    options = [ "subvol=archive" ];
  };
  fileSystems."/var/mnt/media" = {
    device = "/dev/disk/by-uuid/6f6e045e-8a0c-4bdf-9be0-89697d208865";
    fsType = "btrfs";
    options = [ "subvol=media" ];
  };
  fileSystems."/var/mnt/emulation" = {
    device = "/dev/disk/by-uuid/6f6e045e-8a0c-4bdf-9be0-89697d208865";
    fsType = "btrfs";
    options = [ "subvol=emulation" ];
  };
  fileSystems."/var/mnt/longhorn" = {
    device = "/dev/disk/by-uuid/6f6e045e-8a0c-4bdf-9be0-89697d208865";
    fsType = "btrfs";
    options = [ "subvol=longhorn" ];
  };

  # uranium-233
  fileSystems."/var/mnt/backups" = {
    device = "/dev/disk/by-uuid/eec432c4-abd0-491f-b4b0-af2bba294b6b";
    fsType = "btrfs";
    options = [ "defaults" ];
  };

  # nfs bind-mounts
  fileSystems."/var/nfs/archive" = {
    device = "/var/mnt/archive";
    options = [ "bind" ];
  };
  fileSystems."/var/nfs/media" = {
    device = "/var/mnt/media";
    options = [ "bind" ];
  };
  fileSystems."/var/nfs/emulation" = {
    device = "/var/mnt/emulation";
    options = [ "bind" ];
  };
  fileSystems."/var/nfs/backups" = {
    device = "/var/mnt/backups";
    options = [ "bind" ];
  };

  # nfs
  services.nfs.server = {
    enable = true;
    exports = ''
      /var/nfs                *(rw,fsid=0,no_subtree_check)
      /var/nfs/archive        *(rw,nohide,insecure,no_subtree_check)
      /var/nfs/media          *(rw,nohide,insecure,no_subtree_check)
      /var/nfs/emulation      *(rw,nohide,insecure,no_subtree_check)
      /var/nfs/backups        *(rw,no_root_squash,sync)
    '';
  };
}
