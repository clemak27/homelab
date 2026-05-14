{
  den.aspects.starship = {
    nixos =
      { ... }:
      {
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
          hostname = {
            ssh_only = false;
          };
        };
      };
  };
}
