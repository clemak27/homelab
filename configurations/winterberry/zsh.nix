{ config, lib, pkgs, ... }:
{
  config = {
    programs.zsh = {
      enable = true;
      # localVariables = {
      #   # https://unix.stackexchange.com/questions/167582/why-zsh-ends-a-line-with-a-highlighted-percent-symbol
      #   PROMPT_EOL_MARK = "";
      #   ZSH_DISABLE_COMPFIX = false;
      # };
      # oh-my-zsh = {
      #   enable = true;
      #   plugins = [
      #     "extract"
      #     "rsync"
      #     "docker"
      #   ];
      # };
      # shellAliases = builtins.listToAttrs (
      #   [
      #     { name = "cd.."; value = "cd .."; }
      #     { name = "clear_scrollback"; value = "printf '\\33c\\e[3J'"; }
      #     { name = "q"; value = "exit"; }
      #   ]
      # );

      # sessionVariables = {
      #   EDITOR = "nvim";
      #   GIT_SSH = "/usr/bin/ssh";
      #   MANPAGER = "nvim -c 'set ft=man' -";
      #   VISUAL = "nvim";
      # };
      # initExtra = builtins.concatStringsSep "\n" (
      #   [
      #     # no beeps
      #     "unsetopt beep"
      #   ]
      # );
    };

    # programs.dircolors.enable = true;

    # programs.starship.enable = true;
    # programs.starship.enableZshIntegration = true;

    # programs.starship.settings = {
    #   add_newline = false;
    #   line_break = {
    #     disabled = true;
    #   };
    #   kubernetes = {
    #     disabled = true;
    #     format = "[$symbol$context( \($namespace\))]($style) ";
    #   };
    #   directory = {
    #     format = "[ $path]($style)[$read_only]($read_only_style) ";
    #     style = "bold blue";
    #     truncation_length = 99;
    #     truncate_to_repo = false;
    #   };
    #   git_branch = {
    #     format = "[$symbol$branch]($style) ";
    #     symbol = " ";
    #     style = "bold green";
    #   };
    #   git_status = {
    #     style = "bold yellow";
    #   };
    #   nix_shell = {
    #     disabled = false;
    #     format = "[$symbol]($style) ";
    #     symbol = " ";
    #   };
    #   aws = {
    #     disabled = true;
    #   };
    #   battery = {
    #     disabled = true;
    #   };
    #   cmd_duration = {
    #     disabled = true;
    #   };
    #   conda = {
    #     disabled = true;
    #   };
    #   dotnet = {
    #     disabled = true;
    #   };
    #   docker_context = {
    #     disabled = true;
    #   };
    #   elixir = {
    #     disabled = true;
    #   };
    #   elm = {
    #     disabled = true;
    #   };
    #   gcloud = {
    #     disabled = true;
    #   };
    #   golang = {
    #     disabled = true;
    #   };
    #   java = {
    #     disabled = true;
    #   };
    #   julia = {
    #     disabled = true;
    #   };
    #   memory_usage = {
    #     disabled = true;
    #   };
    #   nim = {
    #     disabled = true;
    #   };
    #   nodejs = {
    #     disabled = true;
    #   };
    #   package = {
    #     disabled = true;
    #   };
    #   php = {
    #     disabled = true;
    #   };
    #   python = {
    #     disabled = true;
    #   };
    #   ruby = {
    #     disabled = true;
    #   };
    #   rust = {
    #     disabled = true;
    #   };
    # };
  };
}
