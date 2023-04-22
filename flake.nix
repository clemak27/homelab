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

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, homecfg, sops-nix, flake-utils, nixos-generators, flake-utils-plus }:
    let
      devpkgs = self.pkgs.x86_64-linux.nixpkgs;
    in
    flake-utils-plus.lib.mkFlake {

      # `self` and `inputs` arguments are REQUIRED!
      inherit self inputs;
      channels.nixpkgs.patches = [ ./kustomize.patch ];

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

      outputsBuilder = channels: {

        devShell = channels.nixpkgs.mkShell {
          nativeBuildInputs = with devpkgs; [
            argocd
            kubernetes-helm
            kubectl
            kustomize
            sops
            dnsutils
            yamllint
          ];

          KUSTOMIZE_PLUGIN_HOME = devpkgs.buildEnv {
            name = "kustomize-plugins";
            paths = with devpkgs; [
              kustomize-sops
            ];
            postBuild = ''
              mv $out/lib/* $out
              rm -r $out/lib
            '';
            pathsToLink = [ "/lib" ];
          };
        };
      };
    };
}
