{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.nixos-server = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      common
      server
    ];
  };
}
