# Server commands

| Command | What it does |
| --- | --- |
| **Machine** | |
| `free -h` | RAM and zram swap use |
| `sudo du -sh /var/lib/minecraft/server-world` | world size on disk |
| `sudo ss -tlnp 'sport = :25565'` | check it's listening on the port |
