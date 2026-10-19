{
  flake.modules.homeManager.shell = {
    programs.eza = {
      enable = true;
      colors = "always";
      icons = "auto";
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--long"
        "--header"
        "--all"
      ];
    };
  };
}
