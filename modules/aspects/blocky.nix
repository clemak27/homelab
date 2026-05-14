{
  den.aspects.blocky = {
    nixos =
      { ... }:
      {
        services.blocky = {
          enable = true;
          settings = {
            upstreams = {
              groups = {
                default = [
                  "1.1.1.1"
                  "1.0.0.1"
                  "9.9.9.9"
                  "149.112.112.112"
                ];
              };
            };
            connectIPVersion = "v4";
            customDNS = {
              customTTL = "1h";
              mapping = {
                "wallstreet30.cc" = "192.168.178.100";
              };
            };
            blocking = {
              denylists = {
                ads = [
                  "https =//s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
                  "https =//raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                  "http =//sysctl.org/cameleon/hosts"
                  "https =//s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
                ];
                special = [
                  "https =//raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"
                  "https =//raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.lgwebos.txt"
                ];
              };
            };
            caching = {
              minTime = "5m";
              maxTime = "1h";
            };
            prometheus = {
              enable = false;
            };
            queryLog = {
              type = "none";
            };
            bootstrapDns = [
              "tcp+udp:1.1.1.1"
              "tcp+udp:1.0.0.1"
              "tcp+udp:9.9.9.9"
            ];
            ports = {
              dns = 53;
              http = 4000;
            };
            log = {
              level = "info";
              format = "text";
              timestamp = true;
              privacy = false;
            };
          };
        };
      };
  };
}
