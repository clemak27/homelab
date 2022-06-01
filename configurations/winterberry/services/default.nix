{ config, pkgs, lib, ... }:
{
  imports = [
    ./bumper.nix
    ./deconz.nix
  ];

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
