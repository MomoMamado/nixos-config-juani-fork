{
  flake.modules.nixos.serverConfiguration = {config, ...}: {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = config.ports.immich;
      openFirewall = true;
      mediaLocation = "/data/immich";
    };

    systemd.tmpfiles.rules = ["d /data/immich 0700 immich immich -"];

    systemd.services.immich-server.unitConfig.RequiresMountsFor = "/data/immich";
  };
}
