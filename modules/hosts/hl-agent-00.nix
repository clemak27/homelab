{ hardware, k3s, ... }: {
  den.aspects.hl-agent-00 = {
    includes = [
      hardware.rpi4

      k3s.agent
    ];

    nixos =
      {
        networking.hostName = "hl-agent-00";
      };
  };
}
