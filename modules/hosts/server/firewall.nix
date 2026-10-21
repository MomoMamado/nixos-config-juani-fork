{
  flake.modules.nixos.serverConfiguration = {config, ...}: {
    networking.firewall.allowedTCPPorts = [
      config.ports.trilium
      config.ports.karakeep
    ];
  };
}
