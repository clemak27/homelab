{ config, pkgs, lib, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/Vienna";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "de";
  };
}
