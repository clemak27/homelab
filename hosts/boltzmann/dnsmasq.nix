let
  dnsIP = "192.168.178.100";
  lbIP = "192.168.178.100";
in
{
  networking.firewall.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "enp3s0,wg0";
      listen-address = "::1,127.0.0.1,${dnsIP}";
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      address = [
        "/wallstreet30.cc/${lbIP}"
      ];
    };
  };

  networking.extraHosts = ''
    192.168.178.100 boltzmann
  '';
}
