{
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/home/clemens/key.txt";
  sops.age.generateKey = false;

  sops.secrets."k3s_agent_token" = { };
  sops.secrets."wg/public_key" = { };
  sops.secrets."wg/private_key" = { };
  sops.secrets."wg/enchilada/public_key" = { };
  sops.secrets."wg/enchilada/pre_shared_key" = { };
  sops.secrets."wg/silfur/public_key" = { };
  sops.secrets."wg/silfur/pre_shared_key" = { };
  sops.secrets."wg/deck/public_key" = { };
  sops.secrets."wg/deck/pre_shared_key" = { };
}
