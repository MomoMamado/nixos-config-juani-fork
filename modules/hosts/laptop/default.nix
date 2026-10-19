{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.nixos-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      laptopConfiguration
      common
      homeManager
      desktopEnvironment
      system
      packages
      shell
      cds
      dev
      gaming
    ];
  };
}
