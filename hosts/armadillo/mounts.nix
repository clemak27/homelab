{ config, pkgs, ... }:
{
  # uranium-233
  fileSystems."/var/mnt/hdd" = {
    device = "/dev/disk/by-uuid/5b079fd4-12f0-45e3-8cf4-2cd3ae6d4926";
    fsType = "btrfs";
    # options = [ "subvol=archive" ];
  };

  # nfs bind-mounts
  fileSystems."/var/nfs/archive" = {
    device = "/var/mnt/hdd/archive";
    options = [ "bind" ];
  };
  fileSystems."/var/nfs/media" = {
    device = "/var/mnt/hdd/media";
    options = [ "bind" ];
  };
  fileSystems."/var/nfs/emulation" = {
    device = "/var/mnt/hdd/emulation";
    options = [ "bind" ];
  };
  # fileSystems."/var/nfs/backups" = {
  #   device = "/var/mnt/hdd/backups";
  #   options = [ "bind" ];
  # };

  # nfs
  networking.firewall.enable = false;
  services.nfs.server = {
    enable = true;
    exports = ''
      /var/nfs                *(rw,fsid=0,no_subtree_check)
      /var/nfs/archive        *(rw,nohide,insecure,no_subtree_check)
      /var/nfs/media          *(rw,nohide,insecure,no_subtree_check)
      /var/nfs/emulation      *(rw,nohide,insecure,no_subtree_check)
    '';
    # /var/nfs/backups        *(rw,no_root_squash,sync)
  };
}
