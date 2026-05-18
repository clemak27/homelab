{ den, ... }: {
  den.aspects.clemens = {
    includes = [
      den.aspects.shell
    ];

    nixos =
      { pkgs, ... }:
      {
        time.timeZone = "Europe/Vienna";
        i18n = {
          defaultLocale = "en_GB.UTF-8";
        };
        console.useXkbConfig = true;

        users = {
          users.clemens = {
            uid = 1000;
            shell = pkgs.zsh;
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCyRaO8psuZI2i/+inKS5jn765Uypds8ORj/nVkgSE3 maxwell"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3PSHWVz5/LwHEEfo+7y2o5KH7dlLyfySWnyyi7LLxe newton"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsk9Bh5+4ZsEDFGb7mXDiClvsLwM+jMNr+SPf+auyu7 planck"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjRDUS9h4F+p7C6U+0jJtChS+wMUew7lhwhimuuVAhz lagrange"
            ];
            initialHashedPassword = "$6$iMroX5VfjGgw0a4M$o/IP4Cm44djQt0kXxQbWQh7rIuvVicrckwZPVSj4.Dic3z4jQvxlpdjTMMyVYgVm2V6oIt.OqyMQKY.I.pQ7E0";
          };
        };

        security.sudo.wheelNeedsPassword = false;
        services.openssh.enable = true;
      };
  };
}
