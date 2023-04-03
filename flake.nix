{
  description = "flake for moelab stuff";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.argocd
            pkgs.butane
            pkgs.hadolint
            pkgs.helm
            pkgs.kubectl
            pkgs.kustomize
            pkgs.shellcheck
            pkgs.sops
            pkgs.yamllint
          ];
        };
      });
}
