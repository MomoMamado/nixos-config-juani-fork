{
  flake.modules.nixos.server = {
    fileSystems."/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
      options = ["nofail"];
    };

    fileSystems."/backup" = {
      device = "/dev/disk/by-label/backup";
      fsType = "ext4";
      options = ["nofail" "x-systemd.device-timeout=5s"];
    };
  };
}
