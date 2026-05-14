{
  den.aspects.nvim = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          neovim
        ];
        programs.zsh = {
          shellAliases = builtins.listToAttrs [
            {
              name = "vim";
              value = "nvim";
            }
          ];
        };
        environment.variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };
  };
}
