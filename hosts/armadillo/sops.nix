{ config, lib, pkgs, ... }:
{
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = /home/clemens/homelab/hosts/armadillo/secrets.yaml;
  # # This will automatically import SSH keys as age keys
  # # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/clemens/key.txt";
  # # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = false;
  # # This is the actual specification of the secrets.
  sops.secrets."wg/public_key" = { };
  sops.secrets."wg/private_key" = { };
  sops.secrets."wg/enchilada/public_key" = { };
  sops.secrets."wg/enchilada/pre_shared_key" = { };
  sops.secrets."wg/argentum/public_key" = { };
  sops.secrets."wg/argentum/pre_shared_key" = { };
  sops.secrets."wg/silfur/public_key" = { };
  sops.secrets."wg/silfur/pre_shared_key" = { };
  sops.secrets."wg/deck/public_key" = { };
  sops.secrets."wg/deck/pre_shared_key" = { };
}
