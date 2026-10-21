{
  flake.modules.nixos.serverConfiguration = {config, ...}: {
    services.scrutiny = {
      enable = true;
      openFirewall = true;
      settings.web.listen.port = config.ports.scrutiny;
      collector.schedule = "daily";
    };
  };
}
