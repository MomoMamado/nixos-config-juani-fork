{
  flake.modules.homeManager.desktopEnvironment = {config, ...}: {
    programs.hyprshot = {
      enable = true;
      saveLocation = "${config.home.homeDirectory}/Screenshots";
    };
  };
}
