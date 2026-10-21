{
  flake.modules.nixos.serverConfiguration = {config, ...}: {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString config.ports.karakeep;
        NEXTAUTH_URL = "http://192.168.1.22:${toString config.ports.karakeep}";
        DISABLE_SIGNUPS = "true";
      };
    };

    fileSystems."/var/lib/karakeep" = {
      fsType = "none";
      device = "/data/karakeep";
      options = ["nofail" "bind"];
      depends = ["/data"];
    };

    systemd = {
      tmpfiles.rules = ["d /data/karakeep 0700 karakeep karakeep -"];

      services = {
        karakeep-init.unitConfig.RequiresMountsFor = "/var/lib/karakeep";
        karakeep-workers.unitConfig.RequiresMountsFor = "/var/lib/karakeep";
        karakeep-web.unitConfig.RequiresMountsFor = "/var/lib/karakeep";
      };
    };
  };
}
