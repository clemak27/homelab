{
  sops.defaultSopsFile = /home/clemens/homelab/hosts/deimos/secrets.yaml;
  sops.age.keyFile = "/home/clemens/key.txt";
  sops.age.generateKey = false;

  sops.secrets."k3s_agent_token" = { };
}
