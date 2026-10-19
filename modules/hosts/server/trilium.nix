{
  flake.modules.nixos.serverConfiguration = {config, ...}: {
    services.trilium-server = {
      enable = true;
      host = "0.0.0.0";
      port = config.ports.trilium;
      dataDir = "/data/trilium";
      noBackup = false;
    };

    networking.firewall.allowedTCPPorts = [config.ports.trilium];

    systemd.services.trilium-server.unitConfig.RequiresMountsFor = "/data/trilium";
  };
}
