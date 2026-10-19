{
  flake.modules.nixos.common = {
    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };
  };
}
