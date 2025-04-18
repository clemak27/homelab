{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      pre-commit-hooks,
      deploy-rs,
    }:
    let
      legacyPkgs = nixpkgs.legacyPackages.x86_64-linux;
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
      nixModule = (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ overlay-unstable ];
          nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
          nixpkgs.config = {
            allowUnfree = true;
          };
        }
      );
      defaultModules = [
        nixModule
        sops-nix.nixosModules.sops
        ./modules/general.nix
        ./modules/zsh.nix
      ];
    in
    {
      nixosConfigurations.boltzmann = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = defaultModules ++ [
          ./hosts/boltzmann/configuration.nix
        ];
      };

      deploy.nodes.boltzmann = {
        hostname = "192.168.178.100";
        fastConnection = false;
        interactiveSudo = false;
        user = "root";
        profiles = {
          system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.boltzmann;
          };
        };
      };

      checks.x86_64-linux = {
        pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            actionlint.enable = true;
            yamllint.enable = true;
            commitizen.enable = true;
            kustomize = {
              enable = true;
              name = "kustomize";
              description = "Runs kustomize build";
              files = "kustomization\\.yaml$";
              pass_filenames = true;
              entry =
                let
                  script = legacyPkgs.writeShellScript "pre-commit-kustomize" ''
                    set -e

                    for var in "$@"; do
                      dir="$(dirname $var)"
                      if [[ "$CI" = "true" ]] && [[ -f $dir/secrets.yaml ]]; then
                        echo "---"
                        echo "skipping $dir"
                        echo "---"
                      else
                        kustomize build --enable-helm --enable-exec --enable-alpha-plugins $dir
                      fi
                    done
                  '';
                in
                toString script;
            };
          };
        };
      };

      devShells.x86_64-linux.default = legacyPkgs.mkShell {
        inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;

        packages = with legacyPkgs; [
          argocd
          dnsutils
          doggo
          kubectl
          kubernetes-helm
          kustomize
          pv-migrate
          sops

          nixd
          nixfmt-rfc-style
          nixos-rebuild
          nvd
          legacyPkgs.deploy-rs
        ];

        KUSTOMIZE_PLUGIN_HOME = legacyPkgs.buildEnv {
          name = "kustomize-plugins";
          paths = with legacyPkgs; [
            kustomize-sops
          ];
          postBuild = ''
            mkdir -p $out/viaduct.ai/v1/ksops
            cp $out/lib/viaduct.ai/v1/ksops-exec/ksops-exec $out/viaduct.ai/v1/ksops/ksops
            rm -rf $out/lib
          '';
          pathsToLink = [ "/lib" ];
        };
      };
    };
}
