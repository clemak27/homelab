{ config, pkgs, ... }:
{
  programs.zsh = {
    histSize = 50000;

    shellAliases = builtins.listToAttrs (
      [
        { name = "cd.."; value = "cd .."; }
        { name = "clear"; value = "[[ -e /usr/bin/clear ]] && /usr/bin/clear || printf '\\33c\\e[3J'; [[ -n $TMUX ]] && tmux clearhist;"; }
        { name = "q"; value = "exit"; }
      ]
    );

    shellInit = builtins.concatStringsSep "\n" (
      [
        "PROMPT_EOL_MARK=\"\""
        "export BROWSER=firefox"
        "export DIRENV_LOG_FORMAT=\"\""
        "export EDITOR=vim"
        "export PATH=$PATH:$HOME/.local/bin"
        "export VISUAL=vim"
        "unsetopt beep"
        "setopt HIST_SAVE_NO_DUPS"
        "bindkey -e"
      ]
    );
  };

  programs.starship.enable = true;

  programs.starship.settings = {
    add_newline = false;
    line_break = {
      disabled = true;
    };
    directory = {
      format = "[ $path]($style)[$read_only]($read_only_style) ";
      style = "bold blue";
      truncation_length = 99;
      truncate_to_repo = false;
    };
    nix_shell = {
      disabled = false;
      format = "[$symbol]($style) ";
      symbol = " ";
    };
    battery = {
      disabled = true;
    };
    memory_usage = {
      disabled = true;
    };
  };

}
