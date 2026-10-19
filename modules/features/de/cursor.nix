{
  flake.modules.homeManager.desktopEnvironment = {pkgs, ...}: let
    cursorThemes = {
      bibata = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };
      hackneyed = {
        name = "Hackneyed";
        package = pkgs.hackneyed;
      };
    };

    cursor = cursorThemes.hackneyed;
  in {
    home.pointerCursor = {
      enable = true;
      inherit (cursor) name package;
      size = 24;
      gtk.enable = true;
      hyprcursor.enable = true;
    };
  };
}
