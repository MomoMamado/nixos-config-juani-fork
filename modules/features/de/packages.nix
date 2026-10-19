{
  flake.modules.homeManager.desktopEnvironment = {pkgs, ...}: {
    home.packages = with pkgs; [
      libnotify
      playerctl
      pulseaudio
    ];
  };
}
