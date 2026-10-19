{
  flake.modules.nixos.common = {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    environment.shellAliases = {
      nrs = "sudo nixos-rebuild switch -L --flake ~/nixos-config";
      nfu = "sudo nix flake update --flake ~/nixos-config";
      nrsr = "sudo nixos-rebuild switch --rollback";
    };
  };
}
