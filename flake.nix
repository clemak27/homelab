{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = github:Mic92/sops-nix;
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }:
    let
      devpkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      snowflake = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/e470/configuration.nix
        ];
      };


      devShell.x86_64-linux = devpkgs.mkShell {
        nativeBuildInputs = with devpkgs; [
          sops
          age
          ssh-to-age
        ];
      };
    };
}
