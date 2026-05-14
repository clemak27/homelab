{ den, ... }: {
  den.aspects.shell = {
    includes = [
      den.aspects.nvim
      den.aspects.pkgs
      den.aspects.zsh
    ];
  };
}
