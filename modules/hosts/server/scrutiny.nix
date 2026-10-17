{
  flake.modules.nixos.server = {
    services.scrutiny = {
      enable = true;
      openFirewall = true;
      collector.schedule = "daily";
    };
  };
}
