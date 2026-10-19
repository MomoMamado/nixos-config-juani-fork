{inputs, ...}: {
  flake.modules.homeManager.packages = {
    imports = [inputs.zen-browser.homeModules.default];

    # only what mozilla account doesn't cover
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      profiles.default = {
        id = 0;
        isDefault = true;
        path = "fbj1d5c2.Default Profile"; # the profile zen created, so nothing is lost

        search = {
          force = true;
          default = "ddg";
        };

        settings = {
          "zen.view.window.scheme" = 0; # dark
          "zen.view.use-single-toolbar" = false;
          "browser.translations.automaticallyPopup" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
        };
      };
    };
  };
}
