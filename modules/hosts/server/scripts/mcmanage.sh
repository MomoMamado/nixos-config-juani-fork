#!/usr/bin/env bash

set -euo pipefail

usage(){
  echo "mcmanage cmd <minecraft-server command>"
  echo "mcmanage notify <up|down|maintenance|world-backup>"
  echo "mcmanage backup"
}

cmd(){
  if ! systemctl is-active --quiet minecraft-server; then
    echo "The server isn't running." >&2
    exit 1
  fi
  local since
  since=$(date +%s)
  echo "$*" > "$MC_STDIN"
  sleep 1
  journalctl -u minecraft-server --since "@$since" -o cat --no-pager
}

notify(){
  case $1 in
    up)
      REQUEST='{"embeds": [{"title": "Server Up", "color": 5763719}]}'
      ;;
    down)
      REQUEST='{"embeds": [{"title": "Server Closed", "color": 15548997}]}'
      ;;
    maintenance)
      REQUEST='{"embeds": [{"title": "Server Maintenance", "description": "The server is being updated, it will be back shortly", "color": 3447003}]}'
      ;;
    world-backup)
      REQUEST='{"embeds": [{"title": "Server backing up world...", "color": 15105570}]}'
      ;;
    *)
      echo "Wrong option. Usage:" >&2
      usage
      exit 1
      ;;
  esac

  WEBHOOK_URL=$(cat "$MC_WEBHOOK_URL_FILE")
  curl -sS -f --max-time 10 -o /dev/null -H "Content-Type: application/json" -d "$REQUEST" "$WEBHOOK_URL"
}

stopped(){
  if grep -qsxE 'minecraft-server\.(service|socket)' /run/nixos/start-list /run/nixos/restart-list; then
    notify maintenance
  else
    notify down
  fi
}

backup(){
  [[ $EUID -eq 0 ]] || exec sudo "$0" backup
  if [[ ! -d $BORG_REPO ]]; then
    echo "$BORG_REPO not found, is the backup disk mounted?" >&2
    exit 1
  fi

  notify world-backup || echo "couldn't send the discord notification" >&2

  if systemctl is-active --quiet minecraft-server; then
    trap 'cmd save-on' EXIT

    local since
    since=$(date +%s)
    cmd save-off
    cmd save-all flush

    local saved=false
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

  borg create --stats --compression auto,zstd \
    --exclude "$MC_DIR/logs" \
    --exclude "$MC_DIR/cache" \
    --exclude "$MC_DIR/libraries" \
    --exclude "$MC_DIR/versions" \
    "::minecraft-{now:%Y-%m-%dT%H:%M:%S}" "$MC_DIR"

  borg prune --glob-archives "minecraft-*" --keep-daily 7 --keep-weekly 4 --keep-monthly 6
}

case ${1:-} in
  cmd) shift; cmd "$@" ;;
  notify) notify "${2:-}" ;;
  stopped) stopped ;;
  backup) backup ;;
  *) usage; exit 1 ;;
esac
