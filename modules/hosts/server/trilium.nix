{
  flake.modules.nixos.serverConfiguration = {
    services.trilium-server = {
      enable = true;
      host = "0.0.0.0";
      port = 8081;
      dataDir = "/data/trilium";
      noBackup = false;
    };

    networking.firewall.allowedTCPPorts = [8081];

    systemd.services.trilium-server.unitConfig.RequiresMountsFor = "/data/trilium";
  };
}
