{ den, ... }: {
  den.aspects.zsh = {
    includes = [
      den.aspects.starship
    ];

    nixos =
      { pkgs, ... }:
      {
        users.defaultUserShell = pkgs.zsh;

        programs.zsh = {
          enable = true;
          histSize = 50000;

          shellAliases = builtins.listToAttrs [
            {
              name = "cd..";
              value = "cd ..";
            }
            {
              name = "clear";
              value = "[[ -e /usr/bin/clear ]] && /usr/bin/clear || printf '\\33c\\e[3J';";
            }
            {
              name = "lsa";
              value = "ls -hal";
            }
            {
              name = "q";
              value = "exit";
            }
          ];

          setOptions = [
            "HIST_IGNORE_SPACE"
            "HIST_SAVE_NO_DUPS"
          ];

          shellInit = builtins.concatStringsSep "\n" [
            "PROMPT_EOL_MARK=\"\""
            "unsetopt beep"
            "bindkey -e"
          ];
        };
      };
  };
}
