{ config, pkgs, ... }:
{
  # hdds
  fileSystems."/home/clemens/data0" = {
    device = "/dev/disk/by-uuid/a3f84911-ffdd-4bfb-b9b2-41e372e5a84e";
    fsType = "btrfs";
    options = [ "defaults" ];
  };

  fileSystems."/home/clemens/data0_bu" = {
    device = "/dev/disk/by-uuid/4be7089b-2543-40e8-abcd-c1017395a066";
    fsType = "btrfs";
    options = [ "defaults" ];
  };

  # bind mount hdds to provide them with nfs
  fileSystems."/nfs/archive" = {
    device = "/home/clemens/data0/archive";
    options = [ "bind" ];
  };

  # nfs (potentially sudo mkdir /nfs needed?)
  services.nfs.server = {
    enable = true;
    exports = ''
      /nfs          192.168.178.0/24(rw,fsid=0,no_subtree_check) 10.6.0.0/24(rw,fsid=0,no_subtree_check)
      /nfs/archive  192.168.178.0/24(rw,nohide,insecure,no_subtree_check) 10.6.0.0/24(rw,nohide,insecure,no_subtree_check)
    '';
  };

}
