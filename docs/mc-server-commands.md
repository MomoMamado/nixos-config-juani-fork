# Minecraft server commands

| Command | What it does |
| --- | --- |
| **Service** | |
| `systemctl status minecraft-server` | running or not, uptime, memory use, last log lines |
| `sudo systemctl restart minecraft-server` | restart (saves the world, kicks everyone) |
| `sudo systemctl stop minecraft-server` | stop until the next reboot or rebuild |
| `sudo systemctl start minecraft-server` | start it again |
| **Logs** | |
| `journalctl -u minecraft-server -f` | live log, Ctrl+C to exit |
| `journalctl -u minecraft-server -n 100` | last 100 lines |
| `journalctl -u minecraft-server --since today` | everything from today |
| `journalctl -u minecraft-server --grep "joined\|left"` | who came and went |
| **Console** | |
| `mcmanage cmd list` | who's online |
| `mcmanage cmd tps` | ticks per second for the last 1, 5, 15 min (20 = no lag) |
| `mcmanage cmd mspt` | milliseconds per tick (under 50 = keeping up) |
| `mcmanage cmd op <name>` / `mcmanage cmd deop <name>` | give or take admin |
| `mcmanage cmd say <message>` | message to everyone |
| `mcmanage cmd save-all` | save the world now |
| `mcmanage cmd kick <name>` / `mcmanage cmd ban <name>` | kick or ban a player |
| `mcmanage cmd gamerule <rule> <value>` | change a gamerule, e.g. keep inventory |
| `mcmanage cmd whitelist add <name>` / `mcmanage cmd whitelist remove <name>` | let someone in or out, until the next restart |
| `mcmanage cmd whitelist list` | who's whitelisted right now |
| `mcmanage cmd whitelist reload` | re-read `whitelist.json` from disk |
| **Backup** | |
| `mcmanage backup` | borg backup of the server folder, the server can stay up |
| `sudo systemctl stop minecraft-server && sudo cp -r /var/lib/minecraft/server-world ~/server-world-$(date +%F) && sudo systemctl start minecraft-server` | copy the world to your home folder |

- `mcmanage cmd whitelist add` only lasts until the server restarts: the whitelist is declarative. To make it stick, add the player to the `whitelist` in `modules/hosts/server/features/minecraft.nix` and rebuild.
- That attrset needs the player's UUID: `curl https://api.mojang.com/users/profiles/minecraft/<name>` and add the dashes (8-4-4-4-12).
- To turn the server off for good, set `enable = false;` in that same file and rebuild.
