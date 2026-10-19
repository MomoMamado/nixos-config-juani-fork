{
  flake.modules.nixos.serverConfiguration = {lib, ...}: {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      allowedHosts = "192.168.1.22:8082";

      widgets = [
        {
          resources = {
            label = "System";
            expanded = true;
            cpu = true;
            memory = true;
            cputemp = true;
            uptime = true;
          };
        }
        # one widget per disk: a widget with several disks shows them without names
        {
          resources = {
            label = "System disk";
            expanded = true;
            disk = "/";
          };
        }
        {
          resources = {
            label = "Data disk";
            expanded = true;
            disk = "/data";
          };
        }
        {
          resources = {
            label = "Backup disk";
            expanded = true;
            disk = "/backup";
          };
        }
      ];

      services = [
        {
          "Server" = [
            {
              "Immich" = {
                icon = "immich.png";
                href = "http://192.168.1.22:2283";
                siteMonitor = "http://localhost:2283";
              };
            }
            {
              "Nextcloud" = {
                icon = "nextcloud.png";
                href = "http://192.168.1.22";
                siteMonitor = "http://localhost/status.php";
              };
            }
            {
              "Trilium" = {
                icon = "trilium.png";
                href = "http://192.168.1.22:8081";
                siteMonitor = "http://localhost:8081";
              };
            }
            {
              "Scrutiny" = {
                icon = "scrutiny.png";
                href = "http://192.168.1.22:8080";
                widget = {
                  type = "scrutiny";
                  url = "http://localhost:8080";
                };
              };
            }
            {
              "Minecraft" = {
                icon = "minecraft.png";
                widget = {
                  type = "minecraft";
                  url = "udp://localhost:25565";
                };
              };
            }
          ];
        }
      ];
    };

    # the module's sandbox hides /proc/stat and /proc/meminfo, which the
    # resources widget reads
    systemd.services.homepage-dashboard.serviceConfig.ProcSubset = lib.mkForce "all";
  };
}
