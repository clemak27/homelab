{ config, pkgs, ... }:
{
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  console = {
    keyMap = "de";
  };

  services.openssh.enable = true;

  users.users.clemens = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCyRaO8psuZI2i/+inKS5jn765Uypds8ORj/nVkgSE3 maxwell"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3PSHWVz5/LwHEEfo+7y2o5KH7dlLyfySWnyyi7LLxe newton"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsk9Bh5+4ZsEDFGb7mXDiClvsLwM+jMNr+SPf+auyu7 planck"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjRDUS9h4F+p7C6U+0jJtChS+wMUew7lhwhimuuVAhz lagrange"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    w3m
    git
    parted
    nfs-utils
    cryptsetup
  ];

  boot.kernelModules = [ "dm_crypt" ];

  programs.zsh.enable = true;
}
