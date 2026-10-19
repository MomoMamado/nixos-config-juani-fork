{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.nixos-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      common
      base
      cds
      dev
      gaming
      laptop
    ];
  };
}
