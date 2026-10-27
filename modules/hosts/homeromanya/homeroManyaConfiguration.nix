{
  flake = {
    modules = {
      nixos.homeromanyaConfiguration = {pkgs, ...}: {
        imports = [./_hardware-configuration.nix];

        networking.hostName = "homeromanya";

        users.users.juani.extraGroups = ["video"];

        environment.systemPackages = [pkgs.brightnessctl];

        services = {
          udev.packages = [pkgs.brightnessctl];
          upower.enable = true;
        };

        system.stateVersion = "26.05";
      };

      homeManager.homeromanyaConfiguration = {
        home.stateVersion = "26.05";

        quickshell = {
          enable = true;
          monitor = "eDP-1";
          sliders.edge = "right";
        };

        hyprland.monitors.eDP-1 = {
          mode = "1920x1080@60";
          position = "0x0";
          scale = "1.2";
          workspaces = [1 2 3 4 5 6 7 8 9 10];
        };
      };
    };
  };
}
