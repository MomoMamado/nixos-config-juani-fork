{
  flake.modules.nixos.server = {pkgs, ...}: {
    services.minecraft-server = {
      enable = true;
      package = pkgs.papermcServers.papermc-26_3;
      eula = true;
      openFirewall = true;
      jvmOpts = "-Xms3G -Xmx3G";

      declarative = true;
      serverProperties = {
        motd = "cca y sus amigos";
        server-port = 25565;
        level-name = "server-world";
        level-type = "minecraft:normal";
        gamemode = "survival";
        force-gamemode = true;
        difficulty = "hard";
        max-players = 20;
        view-distance = 12;
        simulation-distance = 8;
        spawn-protection = 0;
        player-idle-timeout = 0;
        pause-when-empty-seconds = 120;
        pvp = true;
        online-mode = true;
        white-list = true;
      };

      whitelist = {
        jidiaz = "4f8e1020-e681-46bd-ac34-100fe7dda18b";
        sloureiro = "82d66e08-20cc-49b5-8072-d10d3720b1ec";
        Hopaness15 = "5e7609ce-32e7-45b4-8892-ac2cea6824ad";
        Chinardooo = "0f894a2b-23e2-453b-b98c-bc0f4dfc69a7";
        _mvnb_ = "2c29be95-b0d5-4443-a520-a48072826928";
        Ferci03 = "6cfea0ad-06f2-481e-bfd4-6b4de466c763";
        OlaBuenas = "b6a233c6-f2ba-4080-a5e1-56c63ac1427e";
      };
    };

    users.users.juani.extraGroups = ["minecraft"];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "mc" ''
        since=$(date +%s)
        echo "$*" > /run/minecraft-server.stdin
        sleep 1
        journalctl -u minecraft-server --since "@$since" -o cat --no-pager
      '')
    ];
  };
}
