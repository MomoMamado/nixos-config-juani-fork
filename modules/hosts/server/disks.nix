{
  flake.modules.nixos.serverConfiguration = {
    fileSystems."/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
      options = ["nofail"];
    };

    fileSystems."/backup" = {
      device = "/dev/disk/by-label/backup";
      fsType = "ext4";
      options = ["nofail" "x-systemd.device-timeout=30s"];
    };
  };
}
