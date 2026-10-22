# Setup

## Minecraft

### Server

The server needs a DuckDNS token to have a Dynamic DNS, to set the token up the following steps should be followed:

1. Go to duckdns.org, create an account and get a token.
2. Create and edit the file where the secret will be stored with `sudoedit /etc/duckdns-token`.
3. Enter the token obtained in step 1.
4. Set the permissions of the file so it can only be read by root with `sudo chmod 600 /etc/duckdns-token`.
5. Create and edit the file that will store the subdomain name with `sudoedit /etc/duckdns-domains`.
6. Enter the name that will be in the domain (just the name, the entire URL will look like `<my-subdomain>.duckdns.org`)
7. Set the permissions of the file so it can only be read by root with `sudo chmod 600 /etc/duckdns-domains`
8. Run `rebuild`.
9. Verify with `journalctl -u duckdns`. It should say `successful` or `Your IP was updated`. Also verify with `nslookup <created-domain>`.

Commands:

```bash
# === token ===
sudoedit /etc/duckdns-token
# paste the duckdns token
sudo chmod 600 /etc/duckdns-token

# === subdomain ===
sudoedit /etc/duckdns-domains
# write the subdomain name
sudo chmod 600 /etc/duckdns-domains

nrs # sudo nixos-rebuild switch -L --flake ~/nixos-config

# === verification ===
journalctl -u duckdns
nslookup <created-url>

```
### Webhooks

1. Go to a discord channel, and get a webhook URL.
2. Create and edit the file where the URL will be stored with `sudoedit /etc/discord-mc-webhook-url`.
3. Enter the URL obtained in step 1.
4. Set the permissions of the file so it can only be read by root with `sudo chmod 600 /etc/discord-mc-webhook-url`.
5. Run `rebuild` and after that run `systemctl restart minecraft-server`.
6. Verify with `systemctl show minecraft-server -p ExecStartPost -p ExecStopPost -p LoadCredential` and `journalctl -u minecraft-server`

Commands:

```bash
# === url ===
sudoedit /etc/discord-mc-webhook-url
# paste the discord webhook url
sudo chmod 600 /etc/discord-mc-webhook-url

nrs # sudo nixos-rebuild switch -L --flake ~/nixos-config

# === verification ===
systemctl show minecraft-server -p ExecStartPost -p ExecStopPost -p LoadCredential
journalctl -u minecraft-server
```

### World backup

The world isn't part of the nightly borg backup, it's backed up manually into the same repo (`/backup/borg`) as `minecraft-<date>` archives. The backup pauses world saving while it runs, so the server can stay up, and sends a notification to the Discord webhook. Old `minecraft-*` archives are pruned (7 daily, 4 weekly, 6 monthly).

1. Run `sudo systemctl start minecraft-backup`. The command returns once the backup is done.
2. Verify with `journalctl -u minecraft-backup`, it should show borg's stats. Also verify with `borg list`, there should be a new `minecraft-<date>` archive.

Commands:

```bash
sudo systemctl start minecraft-backup

# === verification ===
journalctl -u minecraft-backup
systemctl status minecraft-backup
sudo BORG_PASSCOMMAND='cat /etc/borg-passphrase' borg list /backup/borg
```

## Nextcloud 
Nextcloud is used as a self-hosted replacement for OneDrive/Google Drive (file storage and sync). The files are stored in `/data/nextcloud`. To set it up the following steps should be followed:

1. Create the file that stores the admin password with `sudo sh -c 'printf "%s" "<password>" > /etc/nextcloud-admin-pass'` (`printf` is used so the file doesn't end with a newline, which would become part of the password).
2. Set the permissions of the file so it can only be read by root with `sudo chmod 600 /etc/nextcloud-admin-pass`.
3. Make sure the data disk is mounted with `findmnt /data`. Nextcloud won't start without it.
4. Run `rebuild`. The password file must exist before this, otherwise the first setup fails. It's only read on the first install; after that the password is changed from the web UI.
5. Verify with `systemctl status nextcloud-setup phpfpm-nextcloud nginx` and `sudo nextcloud-occ status`. It should say `installed: true`.
6. Open `http://192.168.1.22` and log in with the user `juani` and the password from step 1.
7. On computers, access the files from the browser at `http://192.168.1.22`. On phones, install the Nextcloud app and use `http://192.168.1.22` as the server address.

Commands:

```bash
# === admin password ===
sudo sh -c 'printf "%s" "<password>" > /etc/nextcloud-admin-pass'
sudo chmod 600 /etc/nextcloud-admin-pass

findmnt /data

nrs # sudo nixos-rebuild switch -L --flake ~/nixos-config

# === verification ===
systemctl status nextcloud-setup phpfpm-nextcloud nginx
sudo nextcloud-occ status
```

### Importing existing files

Files can be uploaded through the web UI. For large amounts (for example, a OneDrive export) it's faster to copy them directly into the data dir and make Nextcloud index them:

```bash
sudo cp -r <folder> /data/nextcloud/data/juani/files/
sudo chown -R nextcloud:nextcloud /data/nextcloud/data/juani/files/
sudo nextcloud-occ files:scan juani
```

### Notes

- Major version upgrades (e.g. `nextcloud35` → `nextcloud36`) must be done one version at a time.
- Backups (files and database) run every night, see [backup-setup.md](backup-setup.md).

## Homepage 

Homepage needs some API Keys to show certain service information. The keys should be stored inside /etc/homepage-secrets

### Karakeep

For Karakeep, it is possible to create an API Key from user settings inside the app.

1. Go to where Karakeep is hosted, create an account and get an API key.
2. Create and edit the file where the secret will be stored with `sudoedit /etc/homepage-secrets`.
3. Enter the API key obtained in step 1 with the following format: `HOMEPAGE_VAR_KARAKEEP_KEY=<api-key>`.
4. Set the permissions of the file so it can only be read by root with `sudo chmod 600 /etc/homepage-secrets`.

Commands:

```bash
# === secrets ===
sudoedit /etc/homepage-secrets
# write HOMEPAGE_VAR_KARAKEEP_KEY=<api-key>
sudo chmod 600 /etc/homepage-secrets

nrs # sudo nixos-rebuild switch -L --flake ~/nixos-config
```

### Nextcloud

For Nextcloud, the token isn't created in the app: a random one is generated and Nextcloud is told to accept it. It's the token of the serverinfo app, which can only read the monitoring stats (no login, no files), so it's safer than using the admin password.

1. Generate a random token with `head -c 32 /dev/urandom | base64 | tr -d '\n/+='; echo` and copy it.
2. Tell Nextcloud to accept it with `sudo nextcloud-occ config:app:set serverinfo token --value <token>`. It's stored in Nextcloud's database, so it's included in the nightly backup.
3. Edit the secrets file with `sudoedit /etc/homepage-secrets`.
4. Add a new line with the same token in the following format: `HOMEPAGE_VAR_NEXTCLOUD_KEY=<token>`.
5. Run `rebuild`. If the config didn't change, run `sudo systemctl restart homepage-dashboard` instead, since Homepage only reads the secrets file when it starts.
6. Verify the token with the `curl` command below, it should return JSON with the server info. Also verify Homepage shows numbers on the Nextcloud entry instead of an error. If it fails, check the serverinfo app is enabled with `sudo nextcloud-occ app:list`.

Commands:

```bash
# === token ===
head -c 32 /dev/urandom | base64 | tr -d '\n/+='; echo
sudo nextcloud-occ config:app:set serverinfo token --value <token>

# === secrets ===
sudoedit /etc/homepage-secrets
# add HOMEPAGE_VAR_NEXTCLOUD_KEY=<token>

nrs # sudo nixos-rebuild switch -L --flake ~/nixos-config

# === verification ===
curl -H "NC-Token: <token>" "http://localhost/ocs/v2.php/apps/serverinfo/api/v1/info?format=json"
sudo nextcloud-occ app:list | grep serverinfo
```