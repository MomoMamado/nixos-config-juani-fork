{
  flake.modules.nixos.serverConfiguration = {
    config,
    lib,
    ...
  }: {
    options.serverHost = lib.mkOption {
      type = lib.types.str;
      description = "Hostname or IP of the server, without scheme or port.";
      # magicdns name for tailscale
      default = "nixos-server";
    };

    options.serverUrl = lib.mkOption {
      type = lib.types.str;
      description = "URL of the server.";
      default = "http://${config.serverHost}";
    };
  };
}
