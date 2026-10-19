{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.nixos-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      laptopConfiguration
      common
      base
      cds
      dev
      gaming
    ];
  };
}
