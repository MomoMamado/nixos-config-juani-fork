{
  flake.modules.nixos.serverConfiguration = {
    services.scrutiny = {
      enable = true;
      openFirewall = true;
      collector.schedule = "daily";
    };
  };
}
