{ inputs, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
    (inputs.den.namespace "hardware" true)
    (inputs.den.namespace "k3s" true)
  ];

  den.default.nixos.system.stateVersion = "25.11";

  flake-file.inputs = {
    den.url = "github:vic/den";
    flake-file.url = "github:vic/flake-file";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
}
