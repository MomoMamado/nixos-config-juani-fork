{
  flake.modules.nixos.serverConfiguration = {lib, ...}: {
    options.serverUrl = lib.mkOption {
      type = lib.types.str;
      description = "URL of the server.";
      default = "http://192.168.1.22";
    };
  };
}
