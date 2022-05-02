{ config, pkgs, lib, ... }:
{
  imports = [
    # ./bumper.nix
  ];

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
