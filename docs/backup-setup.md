# Backup setup

Nextcloud and Immich are backed up every night to an external USB disk with [Borg](https://www.borgbackup.org/). The config is in `modules/hosts/server/backup.nix` and the mount in `modules/hosts/server/disks.nix`. Useful commands are in [server-commands.md](server-commands.md).

The Minecraft world isn't part of the nightly backup. It's backed up by hand into the same repository as `minecraft-<date>` archives (see [World backup](server-setup.md#world-backup)), and restored as explained in [The Minecraft world](#the-minecraft-world).

| | |
| --- | --- |
| **What** | `/data/nextcloud`, `/data/immich` and a dump of all PostgreSQL databases (`/var/backup/postgres.sql`) |
| **Where** | `/backup/borg`, on the external disk labelled `backup` |
| **When** | every day at 03:00, or on the next boot if the server was off at that time |
| **How many** | 7 daily, 4 weekly and 6 monthly versions |
| **Encryption** | `repokey-blake2`, passphrase in `/etc/borg-passphrase` |

## How it works

1. Nextcloud is put in maintenance mode, so files and database don't change during the backup.
2. All databases (Nextcloud's and Immich's) are dumped to `/var/backup/postgres.sql`.
3. Borg creates a new archive. Only what changed since the last one is stored (deduplication), so keeping many versions takes little space.
4. Old archives are pruned according to the retention above.
5. Nextcloud leaves maintenance mode. This also happens if the backup fails.

Borg runs inside a systemd sandbox where the whole filesystem is read-only except for `/backup/borg`. Steps 1, 2 and 5 need to write elsewhere, so they run outside the sandbox (`ExecStartPre`/`ExecStopPost` with the `+` prefix).

If the external disk is unplugged, the job fails without writing anything to the system disk, and the server boots normally (it waits 5 seconds for the disk).

## Setup

To set it up the following steps should be followed:

1. Find the disk that will have the backup with `lsblk -o NAME,SIZE,TRAN,MODEL,LABEL`. **Don't touch `sda` (system) or `sdb` (data).**
2. Check it's bigger than what's used in `/data` with `df -h /data`.
3. Wipe it and create a single ext4 partition labelled `backup`. **This erases everything on the disk.**
4. Generate a random passphrase into `/etc/borg-passphrase` and set its permissions so it can only be read by root.
5. Show the passphrase with `sudo cat /etc/borg-passphrase` and save it **outside the server** (password manager or paper). Without it the backups can't be opened.
6. Run `rebuild` and check the disk is mounted with `findmnt /backup`.
7. Create the repository folder with `sudo mkdir -m 700 /backup/borg`. The module also tries to create it on rebuild, but that can happen before the disk is mounted, which makes the job fail with `Failed to set up mount namespacing: /backup/borg: No such file or directory`. It only has to be done once, since the folder lives on the disk.
8. Run the first backup by hand and follow the log. The first run says `/backup/borg is not a valid repository`: that's expected, borg then creates the repository.
9. Verify with `sudo borg-job-data list`. It should show one archive named `nixos-server-data-<date>`.
10. Export the key with `sudo borg-job-data key export --paper` and save the output next to the passphrase. Both are needed to open the backups.
11. Test a restore (see [Restoring](#restoring)).

Commands:

```bash
# === disk ===
lsblk -o NAME,SIZE,TRAN,MODEL,LABEL
df -h /data
sudo wipefs -a /dev/sdX
sudo parted /dev/sdX -- mklabel gpt mkpart backup ext4 0% 100%
sudo mkfs.ext4 -L backup /dev/sdX1

# === passphrase ===
sudo sh -c 'head -c 32 /dev/urandom | base64 | tr -d "\n" > /etc/borg-passphrase'
sudo chmod 600 /etc/borg-passphrase
sudo cat /etc/borg-passphrase; echo
# save it in a password manager

rebuild # sudo nixos-rebuild switch -L --flake ~/nixos-config
findmnt /backup
sudo mkdir -m 700 /backup/borg

# === first backup ===
sudo systemctl start --no-block borgbackup-job-data
journalctl -fu borgbackup-job-data

# === verification ===
sudo borg-job-data list
sudo borg-job-data info
sudo borg-job-data key export --paper
# save it next to the passphrase
systemctl list-timers borgbackup-job-data
```

## Restoring

`borg-job-data` is a wrapper NixOS creates with the repository and passphrase already set. Paths inside an archive have no leading `/` (e.g. `data/nextcloud/...`), and `extract` writes into the **current directory**.

### A file or folder

Extract it into a temporary folder and copy it back to where it belongs:

```bash
sudo borg-job-data list                     # pick an archive
mkdir -p /tmp/restore && cd /tmp/restore
sudo borg-job-data extract ::<archive> data/nextcloud/data/juani/files/<path>
```

If it's a Nextcloud file, copy it back into `/data/nextcloud/data/juani/files/`, fix the owner and rescan:

```bash
sudo cp -r /tmp/restore/data/nextcloud/data/juani/files/<path> /data/nextcloud/data/juani/files/<path>
sudo chown -R nextcloud:nextcloud /data/nextcloud/data/juani/files/
sudo nextcloud-occ files:scan juani
```

The file can also be downloaded from `/tmp/restore` and uploaded through the web UI.

### Everything (e.g. the data disk died)

Not tested yet, only single files have been restored.

1. If the server was reinstalled, recreate `/etc/borg-passphrase` from the saved copy.
2. Mount a new data disk at `/data` (ext4, labelled `data`).
3. Stop everything that uses the data.
4. Extract the latest archive into `/`, which puts the files back in their original paths with their owners.
5. Restore the databases from the dump.
6. Start the services again and take Nextcloud out of maintenance mode: the backup was taken while it was on, so the restored `config.php` has it enabled.
7. Tell the Nextcloud clients the data changed, so they don't overwrite it with older local copies.

```bash
sudo systemctl stop nextcloud-cron.timer phpfpm-nextcloud nginx immich-server
sudo borg-job-data list --glob-archives 'nixos-server-data-*' --last 1 # latest archive name, skipping minecraft-* ones
cd / && sudo borg-job-data extract ::<archive>
sudo cat /var/backup/postgres.sql | sudo -u postgres psql postgres
sudo systemctl start phpfpm-nextcloud nginx immich-server nextcloud-cron.timer
sudo nextcloud-occ maintenance:mode --off
sudo nextcloud-occ maintenance:data-fingerprint
```

### The Minecraft world

The `minecraft-<date>` archives contain `/var/lib/minecraft` (worlds, plugins and server files), without `logs`, `cache`, `libraries` and `versions`, which Paper recreates on start. `server.properties` and the whitelist are rewritten from `minecraft.nix` on every start, so the restored copies don't matter.

1. Pick the archive to restore with `sudo borg-job-data list --glob-archives 'minecraft-*'`.
2. Stop the server with `sudo systemctl stop minecraft-server`.
3. Move the current folder aside to `/var/lib/minecraft.old`. Extracting on top of it would leave behind chunks created after the backup, mixing both versions.
4. Extract the archive into `/`, which puts the files back in `/var/lib/minecraft`.
5. Make sure everything belongs to the `minecraft` user.
6. Start the server, join and check the world is the expected one.
7. Once everything works, delete `/var/lib/minecraft.old`.

```bash
sudo borg-job-data list --glob-archives 'minecraft-*'
sudo systemctl stop minecraft-server
sudo mv /var/lib/minecraft /var/lib/minecraft.old
cd / && sudo borg-job-data extract ::<archive>
sudo chown -R minecraft:minecraft /var/lib/minecraft
sudo systemctl start minecraft-server

# once it works
sudo rm -rf /var/lib/minecraft.old
```

To restore just one dimension, stop the server, move only that folder aside (e.g. `/var/lib/minecraft/server-world_nether`) and add its path to the extract command: `sudo borg-job-data extract ::<archive> var/lib/minecraft/server-world_nether`.

## Notes

- Keep the passphrase and the exported key together, outside the server. If either is lost, the backups can't be opened.
- The external disk is in the same place as the server, so it doesn't protect against fire, theft or a power surge. For that, a second copy has to live somewhere else (e.g. a disk at someone's house).
- `/data/immich/thumbs` and `/data/immich/encoded-video` can be regenerated by Immich. If the disk gets full they can be left out with `exclude` in `backup.nix`.
