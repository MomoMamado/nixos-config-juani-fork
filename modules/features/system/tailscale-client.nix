{
  flake.modules.nixos.system = {
    services.tailscale.enable = true;
  };
}
