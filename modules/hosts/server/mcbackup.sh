#!/usr/bin/env bash

# Backs up the minecraft server dir to the borg repo. Meant to run through
# `sudo systemctl start minecraft-backup`, which sets MC_DIR, MC_STDIN, BORG_REPO
# and BORG_PASSCOMMAND, and loads the webhook credential.

set -euo pipefail

mc() {
  echo "$*" >"$MC_STDIN"
}

mcwebhook world-backup || echo "couldn't send the discord notification" >&2

# the stdin FIFO only exists while the server runs, writing to it otherwise
# would create a regular file in its place
if systemctl is-active --quiet minecraft-server; then
  # turn saving back on whatever happens from here on
  trap 'mc save-on' EXIT

  since=$(date +%s)
  mc save-off
  mc save-all flush

  saved=false
  for _ in $(seq 60); do
    if grep -q "Saved the game" <<<"$(journalctl -u minecraft-server --since "@$since" -o cat)"; then
      saved=true
      break
    fi
    sleep 1
  done

  if [[ $saved == false ]]; then
    echo "minecraft didn't finish saving after 60s, aborting" >&2
    exit 1
  fi
fi

# stuff paper regenerates on its own
borg create --stats --compression auto,zstd \
  --exclude "$MC_DIR/logs" \
  --exclude "$MC_DIR/cache" \
  --exclude "$MC_DIR/libraries" \
  --exclude "$MC_DIR/versions" \
  "::minecraft-{now:%Y-%m-%dT%H:%M:%S}" "$MC_DIR"

# only touches minecraft-* archives, the nightly job prunes its own
borg prune --glob-archives "minecraft-*" --keep-daily 7 --keep-weekly 4 --keep-monthly 6
