{
  flake.modules.nixos.server = {
    config,
    pkgs,
    ...
  }: let
    occ = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
  in {
    # nightly encrypted backup of /data to the external disk (see docs/backup-setup.md)
    services.borgbackup.jobs.data = {
      paths = [
        "/data/nextcloud"
        "/data/immich"
        "/var/backup" # database dump, see ExecStartPre
      ];
      repo = "/backup/borg";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /etc/borg-passphrase";
      };
      compression = "auto,zstd";

      startAt = "*-*-* 03:00:00";
      persistentTimer = true; # run on next boot if the server was off at 3am

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };

    # Borg runs sandboxed (read-only filesystem), but occ needs write access to
    # Nextcloud's dirs, so these run outside it ("+"). Nextcloud is paused so
    # files and database match; ExecStopPost also runs if the backup fails.
    systemd.services.borgbackup-job-data.serviceConfig = {
      ExecStartPre = [
        "+${occ} maintenance:mode --on"
        "+${pkgs.writeShellScript "dump-databases" ''
          set -euo pipefail
          mkdir -p /var/backup
          ${pkgs.util-linux}/bin/runuser -u postgres -- \
            ${config.services.postgresql.package}/bin/pg_dumpall --clean --if-exists > /var/backup/postgres.sql
          chmod 600 /var/backup/postgres.sql
        ''}"
      ];
      ExecStopPost = ["+${occ} maintenance:mode --off"];
    };
  };
}
