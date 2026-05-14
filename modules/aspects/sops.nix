{ inputs, ... }: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.sops = {
    nixos =
      { ... }:
      {
        imports = [
          inputs.sops-nix.nixosModules.sops
        ];

        sops.defaultSopsFile = ./secrets.yaml;
        sops.age.keyFile = "/home/clemens/key.txt";
        sops.age.generateKey = false;
      };
  };
}
