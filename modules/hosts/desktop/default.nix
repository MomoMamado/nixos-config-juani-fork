{
  config,
  inputs,
  ...
}: {
  flake = {
    nixosConfigurations.nixos-desktop = inputs.nixpkgs.lib.nixosSystem {
      modules = with config.flake.modules.nixos; [
        common
        base
        gaming
        dev
        desktop
      ];
    };
  };
}
