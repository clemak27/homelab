{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    zsh
    wget
    curl
    vim

    dnsutils
    tcpdump
    iptables
  ];
}
