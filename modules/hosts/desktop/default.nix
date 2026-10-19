{
  config,
  inputs,
  ...
}: {
  flake = {
    nixosConfigurations.nixos-desktop = inputs.nixpkgs.lib.nixosSystem {
      modules = with config.flake.modules.nixos; [
        desktopConfiguration
        common
        homeManager
        desktopEnvironment
        system
        packages
        shell
        gaming
        dev
      ];
    };
  };
}
