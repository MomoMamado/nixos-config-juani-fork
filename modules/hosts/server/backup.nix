{
  flake.modules.nixos.server = {
    config,
    pkgs,
    ...
  }: let
    occ = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
  in {
    # nightly encrypted backup of /data to the external disk (see docs/server-setup.md)
    services.borgbackup.jobs.data = {
      paths = [
        "/data/nextcloud"
        "/data/immich"
        "/var/backup" # database dump, see preHook
      ];
      repo = "/backup/borg";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /etc/borg-passphrase";
      };
      compression = "auto,zstd";

      # the job only sees a read-only filesystem besides these
      readWritePaths = [
        "/var/backup" # database dump
        "/data/nextcloud/config" # occ maintenance:mode writes config.php
      ];

      startAt = "*-*-* 03:00:00";
      persistentTimer = true; # run on next boot if the server was off at 3am

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };

      # Nextcloud is paused so files and database match; postHook also runs if the backup fails
      preHook = ''
        ${occ} maintenance:mode --on
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.package}/bin/pg_dumpall --clean --if-exists > /var/backup/postgres.sql
        chmod 600 /var/backup/postgres.sql
      '';
      postHook = ''
        ${occ} maintenance:mode --off
      '';
    };

    # read-write paths must exist before the job starts
    systemd.tmpfiles.rules = ["d /var/backup 0700 root root -"];
  };
}
