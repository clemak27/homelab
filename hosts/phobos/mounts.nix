{ pkgs, ... }:
let
  mountDisks = pkgs.writeShellScriptBin "init-disks" ''
    partition="/dev/disk/by-uuid/170bfbea-0807-499b-973e-f7df73d006ec"
    luksMapper="cryptdata"
    unencryptedDisk="/dev/mapper/$luksMapper"

    cryptsetup open "$partition" "$luksMapper"

    mkdir -p /var/lib/rancher/k3s/data
    mkdir -p /var/mnt/longhorn

    mount -o compress=zstd,subvol=k3s $unencryptedDisk /var/lib/rancher/k3s/data
    mount -o compress=zstd,subvol=longhorn $unencryptedDisk /var/mnt/longhorn

    # sudo systemctl start k3s.service
  '';
in
{
  environment.systemPackages = [
    mountDisks
  ];

  # swap
  swapDevices = [{
    device = "/swapfile";
    size = 8 * 1024;
  }];
}
