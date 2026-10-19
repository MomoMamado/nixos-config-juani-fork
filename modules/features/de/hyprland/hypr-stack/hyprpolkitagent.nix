{
  flake.modules.homeManager.desktopEnvironment = _: {
    services.hyprpolkitagent.enable = true;
  };
}
