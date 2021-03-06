{ config, lib, pkgs, ... }:
{
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ./secrets.yaml;
  # # This will automatically import SSH keys as age keys
  # # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/clemens/.config/sops/age/keys.txt";
  # # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = false;
  # # This is the actual specification of the secrets.
  sops.secrets."cloudflare_api_key" = { };

  sops.secrets."wg/public_key" = { };
  sops.secrets."wg/private_key" = { };
  sops.secrets."wg/onedroid/public_key" = { };
  sops.secrets."wg/onedroid/pre_shared_key" = { };
  sops.secrets."wg/argentum/public_key" = { };
  sops.secrets."wg/argentum/pre_shared_key" = { };
  sops.secrets."wg/silfur/public_key" = { };
  sops.secrets."wg/silfur/pre_shared_key" = { };
  sops.secrets."wg/deck/public_key" = { };
  sops.secrets."wg/deck/pre_shared_key" = { };

  sops.secrets."docker/pihole_pw" = { };
  sops.secrets."docker/miniflux_admin_user" = { };
  sops.secrets."docker/miniflux_admin_password" = { };
  sops.secrets."docker/miniflux_db_user" = { };
  sops.secrets."docker/miniflux_db_password" = { };
  sops.secrets."docker/deemix_arl" = { };
  sops.secrets."docker/fireflyiii_app_key" = { };
  sops.secrets."docker/fireflyiii_db_name" = { };
  sops.secrets."docker/fireflyiii_db_user" = { };
  sops.secrets."docker/fireflyiii_db_password" = { };
  sops.secrets."docker/recipes_secret_key" = { };
  sops.secrets."docker/recipes_db_user" = { };
  sops.secrets."docker/recipes_db_password" = { };
  sops.secrets."docker/recipes_db_name" = { };
  sops.secrets."docker/vaultwarden_yubico_client_id" = { };
  sops.secrets."docker/vaultwarden_yubico_secret_key" = { };
}
