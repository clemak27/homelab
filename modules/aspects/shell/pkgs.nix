{
  den.aspects.pkgs = {
    nixos =
      { pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;
        nix = {
          settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            trusted-users = [
              "root"
              "@wheel"
            ];
          };
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
        };
        environment.systemPackages = with pkgs; [
          curl
          git
          nixos-rebuild
          parted
          wget
        ];
      };
  };
}
