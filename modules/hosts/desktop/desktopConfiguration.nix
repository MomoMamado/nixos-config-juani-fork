{
  flake.modules = {
    nixos.desktopConfiguration = {pkgs, ...}: {
      imports = [./_hardware-configuration.nix];

      networking.hostName = "nixos-desktop";

      hardware.ckb-next.enable = true;

      programs.solaar = {
        enable = true;
        userService.enable = true;
      };

      system.stateVersion = "26.05";
    };

    homeManager.desktopConfiguration = {pkgs, ...}: {
      home.stateVersion = "26.05";

      systemd.user.services.ckb-next = {
        Unit = {
          Description = "ckb-next keyboard bindings";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };

        Service = {
          ExecStart = "${pkgs.ckb-next}/bin/ckb-next --background";
          Restart = "on-failure";
          Slice = "session.slice";
        };

        Install.WantedBy = ["graphical-session.target"];
      };

      quickshell = {
        enable = true;
        monitor = "DP-3";
        sliders.edge = "right";
      };

      hyprland.monitors = {
        DP-3 = {
          mode = "1920x1080@144";
          position = "0x0";
          scale = "1";
          workspaces = [1 2 3 4 5];
        };

        HDMI-A-1 = {
          mode = "1920x1080@60";
          position = "1920x0";
          scale = "1";
          workspaces = [6 7 8 9 10];
        };
      };
    };
  };
}
