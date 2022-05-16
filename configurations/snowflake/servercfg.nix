{ config, pkgs, lib, ... }:
{
  options.servercfg = {
    data_dir = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The directory which contains the data for the docker-containers";
      example = "/docker";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The domain of the server";
      example = "example.com";
    };
  };

  config.servercfg.data_dir = "/home/clemens/data0/docker";
  config.servercfg.domain = "wallstreet30.cc";
}
