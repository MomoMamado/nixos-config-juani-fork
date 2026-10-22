{
  flake.modules.nixos.serverConfiguration = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    networking.firewall.trustedInterfaces = ["tailscale0"];
  };
}
