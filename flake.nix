{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = github:Mic92/sops-nix;
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, flake-utils }:
    let
      devpkgs = nixpkgs.legacyPackages.x86_64-linux;
      devpkgs-arm = nixpkgs.legacyPackages.aarch64-linux;
      updateServers = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "update-flake" ''
        echo "Updating flake"
        nix flake update --commit-lock-file --commit-lockfile-summary "chore(flake): Update $(date -I)"

        echo "Pushing update to server"
        git push
      '';

    in
    {
      nixosConfigurations = {
        snowflake = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./configurations/snowflake/configuration.nix
          ];
        };

        winterberry = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./configurations/winterberry/configuration.nix
          ];
        };
      };

      devShell.x86_64-linux = devpkgs.mkShell {
        nativeBuildInputs = with devpkgs; [
          sops
          age
          ssh-to-age
          updateServers
          nmap
          dnsutils
        ];
      };

      devShell.aarch64-linux = devpkgs-arm.mkShell {
        nativeBuildInputs = with devpkgs-arm; [
          sops
          age
          ssh-to-age
          usbutils
        ];
      };

    };
}
