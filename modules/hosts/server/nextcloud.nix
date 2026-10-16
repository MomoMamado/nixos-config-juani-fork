{
  flake.modules.nixos.server = {pkgs, ...}: {
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

    networking.firewall.allowedTCPPorts = [80];

    systemd.tmpfiles.rules = ["d /data/nextcloud 0750 nextcloud nextcloud -"];

    systemd.services = {
      nextcloud-setup.unitConfig.RequiresMountsFor = "/data/nextcloud";
      phpfpm-nextcloud.unitConfig.RequiresMountsFor = "/data/nextcloud";
      nextcloud-cron.unitConfig.RequiresMountsFor = "/data/nextcloud";
    };
  };
}
