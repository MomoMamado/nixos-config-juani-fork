{
  flake.modules.homeManager.desktopEnvironment = {pkgs, ...}: {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.go-mono
      nerd-fonts.bigblue-terminal
    ];
  };
}
