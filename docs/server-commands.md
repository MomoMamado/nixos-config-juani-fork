# Server commands

## General use

| Command | What it does |
| --- | --- |
| **Machine** | |
| `free -h` | RAM and zram swap use |
| `sudo du -sh /var/lib/minecraft/server-world` | world size on disk |
| `sudo ss -tlnp 'sport = :25565'` | check it's listening on the port |

## Borg backups

| Command | What it does |
| --- | --- |
| **Status** | |
| `systemctl list-timers borgbackup-job-data` | when the last backup ran and when the next one runs |
| `systemctl status borgbackup-job-data` | result of the last run, or progress if it's running |
| `findmnt /backup` | check the external disk is mounted |
| `df -h /backup` | space used and free on the external disk |
| **Logs** | |
| `journalctl -u borgbackup-job-data -f` | live log, Ctrl+C to exit |
| `journalctl -u borgbackup-job-data -n 50` | last 50 lines |
| `journalctl -u borgbackup-job-data --since today` | everything from today |
| **Run** | |
| `sudo systemctl start --no-block borgbackup-job-data` | back up now, in the background |
| `sudo systemctl stop borgbackup-job-data` | cancel a running backup (Nextcloud leaves maintenance mode) |
| **Archives** | |
| `sudo borg-job-data list` | all archives (one per kept backup) |
| `sudo borg-job-data list --last 1` | latest archive |
| `sudo borg-job-data info` | total size, and deduplicated size actually used on disk |
| `sudo borg-job-data info ::<archive>` | size and duration of one archive |
| `sudo borg-job-data list ::<archive> \| grep <name>` | find a file inside an archive |
| `sudo borg-job-data diff ::<older> <newer>` | what changed between two archives |
| **Restore** | |
| `sudo borg-job-data extract ::<archive> <path>` | extract a file or folder into the current directory |
| `sudo borg-job-data extract --dry-run --list ::<archive> <path>` | show what would be extracted, without writing |
| **Maintenance** | |
| `sudo borg-job-data check` | verify the repository isn't corrupted (takes a while) |
| `sudo borg-job-data check --verify-data` | also read and verify every file's contents (slow) |
| `sudo borg-job-data key export --paper` | print the key, to save next to the passphrase |
| `sudo borg-job-data break-lock` | remove a stale lock after a crash, **only if no backup is running** |
| **Nextcloud** | |
| `curl -s localhost/status.php` | `"maintenance":true` while a backup runs |
| `sudo nextcloud-occ maintenance:mode --off` | take Nextcloud out of maintenance mode if it got stuck |

- `borg-job-data` is plain `borg` with the repository and passphrase already set, so any [borg command](https://borgbackup.readthedocs.io/en/stable/usage/general.html) works with it.
- Archives are named `nixos-server-data-<date>`. In commands, write them as `::<archive>`.
- Paths inside an archive have no leading `/`: `data/nextcloud/data/juani/files/...`, not `/data/nextcloud/...`.
- `extract` writes into the directory you're in, so `cd` into an empty folder like `/tmp/restore` first, unless you want to overwrite the originals.
