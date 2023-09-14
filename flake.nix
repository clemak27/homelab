{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    sops-nix.url = "github:Mic92/sops-nix";
    # flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, sops-nix, pre-commit-hooks }:
    let
      legacyPkgs = nixpkgs.legacyPackages.x86_64-linux;
      overlay-stable = final: prev: {
        stable = nixpkgs-stable.legacyPackages.x86_64-linux;
      };
      nixModule = ({ config, pkgs, ... }: {
        nixpkgs.overlays = [ overlay-stable ];
        nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
        nixpkgs.config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "nodejs-16.20.0"
            "nodejs-16.20.1"
            "nodejs-16.20.2"
          ];
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
      nixosConfigurations.nuke = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
          ./hosts/nuke/configuration.nix
        ];
      };

      nixosConfigurations.phobos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = defaultModules ++ [
          ./hosts/phobos/configuration.nix
        ];
      };

      nixosConfigurations.deimos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = defaultModules ++ [
          ./hosts/deimos/configuration.nix
        ];
      };

      checks.x86_64-linux = {
        pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            actionlint.enable = true;
            yamllint.enable = true;
          };
        };
      };

      devShells.x86_64-linux.default =
        let
          updateArgoCDApplications = legacyPkgs.writeShellScriptBin "update-argocd-applications" ''
            find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;
          '';
        in
        legacyPkgs.mkShell {
          inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;

          packages = with legacyPkgs; [
            updateArgoCDApplications

            argocd
            dnsutils
            kubectl
            kubernetes-helm
            kustomize
            sops
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
