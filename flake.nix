{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homecfg = {
      url = "github:clemak27/homecfg";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, homecfg, sops-nix, flake-utils, nixos-generators }:
    let
      devpkgs = nixpkgs.legacyPackages.x86_64-linux;
      overlay-stable = final: prev: {
        stable = self.inputs.nixpkgs-stable.legacyPackages.x86_64-darwin;
      };
    in
    {
      nixosConfigurations = {
        nuke = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ./hosts/nuke/configuration.nix
            ./modules/dns.nix
            ./modules/general.nix
            ./modules/gitops.nix
            ./modules/k3s.nix
            ./modules/zsh.nix
          ];
        };

        virtual = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ./hosts/virtual/configuration.nix
            ./modules/general.nix
            ./modules/gitops.nix
            # ./modules/dns.nix
            ./modules/k3s.nix
            ./modules/zsh.nix
          ];
        };
      };

      devShell.x86_64-linux = devpkgs.mkShell {
        nativeBuildInputs = with devpkgs; [
          argocd
          kubernetes-helm
          kubectl
          kustomize
          sops
          dnsutils
          yamllint
        ];
      };
    };
}
