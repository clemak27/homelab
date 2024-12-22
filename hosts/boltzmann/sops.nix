{
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/home/clemens/key.txt";
  sops.age.generateKey = false;

  sops.secrets."wg/public_key" = { };
  sops.secrets."wg/private_key" = { };
  sops.secrets."wg/planck/public_key" = { };
  sops.secrets."wg/planck/pre_shared_key" = { };
  sops.secrets."wg/newton/public_key" = { };
  sops.secrets."wg/newton/pre_shared_key" = { };
  sops.secrets."wg/fermi/public_key" = { };
  sops.secrets."wg/fermi/pre_shared_key" = { };
  sops.secrets."wg/w2h/public_key" = { };
  sops.secrets."wg/w2h/pre_shared_key" = { };
  sops.secrets."wg/lagrange/public_key" = { };
  sops.secrets."wg/lagrange/pre_shared_key" = { };
}
