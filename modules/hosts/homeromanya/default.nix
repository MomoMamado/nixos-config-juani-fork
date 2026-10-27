{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.homeromanya = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      homeromanyaConfiguration
      common
      homeManager
      desktopEnvironment
      system
      packages
      shell
      gaming
    ];
  };
}
