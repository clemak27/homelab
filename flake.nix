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

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, homecfg, sops-nix, flake-utils-plus }:
    let
      pkgs = self.pkgs.x86_64-linux.nixpkgs;
      UpdateArgoCDApplications = pkgs.writeShellScriptBin "update-argocd-applications" ''
        find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;
      '';
    in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" ];

      channels.nixpkgs = {
        config = { allowUnfree = true; };
        overlaysBuilder = channels: [
          (final: prev: { stable = self.inputs.nixpkgs-stable.legacyPackages.x86_64-linux; })
        ];
        patches = [ ./kustomize.patch ];
      };

      hostDefaults = {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./modules/general.nix
          ./modules/zsh.nix
        ];
        channelName = "nixpkgs";
      };

      hosts = {
        nuke = {
          modules = [
            ./hosts/nuke/configuration.nix
            ./modules/dns.nix
            ./modules/gitops.nix
            ./modules/k3s.nix
          ];
        };

        virtual = {
          modules = [
            ./hosts/virtual/configuration.nix
          ];
        };
      };

      outputsBuilder = channels: {
        devShell = channels.nixpkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            UpdateArgoCDApplications
            argocd
            kubernetes-helm
            kubectl
            kustomize
            sops
            dnsutils
            yamllint
          ];

          KUSTOMIZE_PLUGIN_HOME = pkgs.buildEnv {
            name = "kustomize-plugins";
            paths = with pkgs; [
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
