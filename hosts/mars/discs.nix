{
  # mc-00
  fileSystems."/var/mnt/longhorn" = {
    device = "/dev/disk/by-uuid/61adb607-87aa-429e-95ad-180cf2851f59";
    fsType = "ext4";
  };

  # mc-01
  fileSystems."/var/mnt/media" = {
    device = "/dev/disk/by-uuid/b2c20ad4-3a1a-4656-abea-d9f774170726";
    fsType = "btrfs";
    options = [ "subvol=media" ];
  };

  # mc-02
  fileSystems."/var/mnt/backups" = {
    device = "/dev/disk/by-uuid/6f4c22d1-60c8-4f91-a2b4-c04f30b77f45";
    fsType = "btrfs";
    options = [ "subvol=backups" ];
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

  networking.firewall.enable = false;
  services.nfs.server = {
    enable = true;
    exports = ''
      /var/nfs                *(rw,fsid=0,no_subtree_check)
      /var/nfs/media          *(rw,nohide,insecure,no_subtree_check)
      /var/nfs/backups        *(rw,no_root_squash,sync)
    '';
  };
}
