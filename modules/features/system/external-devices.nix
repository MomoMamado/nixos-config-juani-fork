{
  flake.modules.nixos.base = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services = {
      printing.enable = true;
      udisks2.enable = true;
    };
  };
}
