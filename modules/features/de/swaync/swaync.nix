{
  flake.modules.homeManager.desktopEnvironment = {lib, ...}: {
    services.swaync = {
      enable = true;
      style = ./style.css;
    };

    xdg.configFile."swaync/config.json".source = lib.mkForce ./config.json;
  };
}
