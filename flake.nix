{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, pre-commit-hooks }:
    let
      legacyPkgs = nixpkgs.legacyPackages.x86_64-linux;
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
      nixModule = ({ config, pkgs, ... }: {
        nixpkgs.overlays = [ overlay-unstable ];
        nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
        nixpkgs.config = {
          allowUnfree = true;
        };
      });
      defaultModules = [
        nixModule
        sops-nix.nixosModules.sops
        ./modules/general.nix
        ./modules/zsh.nix
      ];
    in
    {
      nixosConfigurations.mars = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
          ./hosts/mars/configuration.nix
        ];
      };

      checks.x86_64-linux = {
        pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            actionlint.enable = true;
            yamllint.enable = true;
            checkmake.enable = true;
          };
        };
      };

      devShells.x86_64-linux.default =
        legacyPkgs.mkShell {
          inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;

          packages = with legacyPkgs; [
            argocd
            dnsutils
            kubectl
            kubernetes-helm
            kustomize
            pv-migrate
            sops
            nixos-rebuild
          ];

          KUSTOMIZE_PLUGIN_HOME = legacyPkgs.buildEnv {
            name = "kustomize-plugins";
            paths = with legacyPkgs; [
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
}
