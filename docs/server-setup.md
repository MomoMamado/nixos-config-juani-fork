# Setup

## Minecraft

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

rebuild # sudo nixos-rebuild switch -L --flake ~/nixos-config

# === verification ===
journalctl -u duckdns
nslookup <created-url>
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

rebuild # sudo nixos-rebuild switch -L --flake ~/nixos-config

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
