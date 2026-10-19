{
  flake.modules.homeManager.packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      bluetui
      wiremix
      kew
      tldr
    ];

    programs = {
      imv.enable = true;
      yazi.enable = true;
      fzf.enable = true;
      ripgrep.enable = true;
      btop = {
        enable = true;
        settings = {
          color_theme = "adapta";
        };
      };
    };
  };
}
