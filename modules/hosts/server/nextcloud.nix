{
  flake.modules.nixos.serverConfiguration = {
    config,
    pkgs,
    ...
  }: {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud35;
      hostName = "192.168.1.22";
      datadir = "/data/nextcloud";
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "16G";

      config = {
        dbtype = "pgsql";
        adminuser = "juani";
        adminpassFile = "/etc/nextcloud-admin-pass";
      };

      settings.trusted_domains = ["nixos-server"];
    };

    # nginx serves nextcloud; listen is set so the port follows ports.nix
    services.nginx.virtualHosts.${config.services.nextcloud.hostName}.listen = [
      {
        addr = "0.0.0.0";
        port = config.ports.nextcloud;
      }
      {
        addr = "[::]";
        port = config.ports.nextcloud;
      }
    ];

    networking.firewall.allowedTCPPorts = [config.ports.nextcloud];

    systemd.tmpfiles.rules = ["d /data/nextcloud 0750 nextcloud nextcloud -"];

    systemd.services = {
      nextcloud-setup.unitConfig.RequiresMountsFor = "/data/nextcloud";
      phpfpm-nextcloud.unitConfig.RequiresMountsFor = "/data/nextcloud";
      nextcloud-cron.unitConfig.RequiresMountsFor = "/data/nextcloud";
    };
  };
}
