#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "mcwebhook [up|down|maintenance|world-backup]"
}

# the value of the first parameter or an empty string if empty or unset
if [[ -z ${1:-} ]]; then
  usage
  exit 1
fi

notify() {
  case $1 in
  "up")
    REQUEST='{"embeds": [{"title": "Server Up", "color": 5763719}]}'
    ;;

  "down")
    REQUEST='{"embeds": [{"title": "Server Closed", "color": 15548997}]}'
    ;;

  "maintenance")
    REQUEST='{"embeds": [{"title": "Server Maintenance", "description": "The server is being updated, it will be back shortly", "color": 3447003}]}'
    ;;

  "world-backup")
    REQUEST='{"embeds": [{"title": "Server backing up world...", "color": 15105570}]}'
    ;;

  *)
    echo "Wrong option. Usage: "
    usage
    exit 1
    ;;
  esac

  # systemd doesn't pass credentials to ExecStopPost, so there the url file is read directly
  if [[ -n ${CREDENTIALS_DIRECTORY:-} ]]; then
    WEBHOOK_URL=$(cat "$CREDENTIALS_DIRECTORY"/mc-ds-webhook)
  else
    WEBHOOK_URL=$(cat "$MC_WEBHOOK_URL_FILE")
  fi
  curl -sS -f --max-time 10 -o /dev/null -H "Content-Type: application/json" -d "$REQUEST" "$WEBHOOK_URL"
}

notify "$@"
