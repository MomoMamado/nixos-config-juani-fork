{
  flake.modules.nixos.desktopConfiguration = {
    services.pipewire.wireplumber.extraConfig."51-rename-outputs" = {
      "monitor.alsa.rules" = [
        {
          matches = [{"node.name" = "alsa_output.pci-0000_08_00.6.iec958-stereo";}];
          actions.update-props."node.description" = "Parlantes Edifier";
        }
        {
          matches = [{"node.name" = "alsa_output.pci-0000_08_00.6.analog-stereo";}];
          actions.update-props."node.description" = "Auriculares";
        }
        {
          matches = [{"node.name" = "alsa_output.pci-0000_01_00.1.hdmi-stereo";}];
          actions.update-props."node.description" = "Monitor (HDMI)";
        }
      ];
    };
  };
}
