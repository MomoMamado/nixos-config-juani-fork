{
  flake.modules.nixos.serverConfiguration = {
    config,
    lib,
    ...
  }: let
    inherit (config) ports;
  in {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      listenPort = ports.homepage;
      allowedHosts = "192.168.1.22:${toString ports.homepage}";
      environmentFiles = ["/etc/homepage-secrets"];

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
                href = "http://192.168.1.22:${toString ports.immich}";
                siteMonitor = "http://localhost:${toString ports.immich}";
                widget = {
                  type = "immich";
                  url = "http://localhost:${toString ports.immich}";
                  key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                  version = 2;
                };
              };
            }
            {
              "Nextcloud" = {
                icon = "nextcloud.png";
                href = "http://192.168.1.22:${toString ports.nextcloud}";
                siteMonitor = "http://localhost:${toString ports.nextcloud}/status.php";
                widget = {
                  type = "nextcloud";
                  url = "http://localhost:${toString ports.nextcloud}";
                  key = "{{HOMEPAGE_VAR_NEXTCLOUD_KEY}}";
                };
              };
            }
            {
              "Trilium" = {
                icon = "trilium.png";
                href = "http://192.168.1.22:${toString ports.trilium}";
                siteMonitor = "http://localhost:${toString ports.trilium}";
              };
            }
            {
              "Karakeep" = {
                icon = "karakeep.png";
                href = "http://192.168.1.22:${toString ports.karakeep}";
                siteMonitor = "http://localhost:${toString ports.karakeep}";
                widget = {
                  type = "karakeep";
                  url = "http://localhost:${toString ports.karakeep}";
                  key = "{{HOMEPAGE_VAR_KARAKEEP_KEY}}";
                };
              };
            }
            {
              "Scrutiny" = {
                icon = "scrutiny.png";
                href = "http://192.168.1.22:${toString ports.scrutiny}";
                widget = {
                  type = "scrutiny";
                  url = "http://localhost:${toString ports.scrutiny}";
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
