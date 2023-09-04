{ config, pkgs, ... }:
{
  # enriched-uranium
  # fileSystems."/var/mnt/archive" = {
  #   device = "/dev/disk/by-uuid/31e021ea-9e33-4ab3-bb50-8940c4da43ac";
  #   fsType = "btrfs";
  #   options = [ "subvol=archive" ];
  # };
  # fileSystems."/var/mnt/media" = {
  #   device = "/dev/disk/by-uuid/31e021ea-9e33-4ab3-bb50-8940c4da43ac";
  #   fsType = "btrfs";
  #   options = [ "subvol=media" ];
  # };
  # fileSystems."/var/mnt/emulation" = {
  #   device = "/dev/disk/by-uuid/31e021ea-9e33-4ab3-bb50-8940c4da43ac";
  #   fsType = "btrfs";
  #   options = [ "subvol=emulation" ];
  # };
  # fileSystems."/var/mnt/longhorn" = {
  #   device = "/dev/disk/by-uuid/31e021ea-9e33-4ab3-bb50-8940c4da43ac";
  #   fsType = "btrfs";
  #   options = [ "subvol=longhorn" ];
  # };

  # coolant
  # fileSystems."/var/mnt/backups" = {
  #   device = "/dev/disk/by-uuid/87850e16-1642-4e0c-b9c0-2c94adc63d5e";
  #   fsType = "btrfs";
  #   options = [ "subvol=backups" ];
  # };

  # nfs bind-mounts
  # fileSystems."/var/nfs/archive" = {
  #   device = "/var/mnt/archive";
  #   options = [ "bind" ];
  # };
  # fileSystems."/var/nfs/media" = {
  #   device = "/var/mnt/media";
  #   options = [ "bind" ];
  # };
  # fileSystems."/var/nfs/emulation" = {
  #   device = "/var/mnt/emulation";
  #   options = [ "bind" ];
  # };
  # fileSystems."/var/nfs/backups" = {
  #   device = "/var/mnt/backups";
  #   options = [ "bind" ];
  # };

  # nfs
  # services.nfs.server = {
  #   enable = true;
  #   exports = ''
  #     /var/nfs                *(rw,fsid=0,no_subtree_check)
  #     /var/nfs/archive        *(rw,nohide,insecure,no_subtree_check)
  #     /var/nfs/media          *(rw,nohide,insecure,no_subtree_check)
  #     /var/nfs/emulation      *(rw,nohide,insecure,no_subtree_check)
  #     /var/nfs/backups        *(rw,no_root_squash,sync)
  #   '';
  # };
}
