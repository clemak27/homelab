{ hardware, k3s, den, ... }: {
  den.aspects.hl-agent-01 = {
    includes = [
      hardware.rpi4

      k3s.agent

      den.batteries.user-aspects
    ];

    nixos =
      {
        networking.hostName = "hl-agent-01";
      };
  };
}
