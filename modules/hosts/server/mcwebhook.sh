#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "mcwebhook [up|down|world-backup]"
}

# the value of the first parameter or an empty string if empty or unset
if [[ -z ${1:-} ]]; then
  usage
  exit 1
fi

notify() {
  case $1 in
  "up")
    REQUEST='{"embeds": [{"title": "Server Up"}]}'
    ;;

  "down")
    REQUEST='{"embeds": [{"title": "Server Closed"}]}'
    ;;

  "world-backup")
    REQUEST='{"embeds": [{"title": "Server backing up world..."}]}'
    ;;

  *)
    echo "Wrong option. Usage: "
    usage
    exit 1
    ;;
  esac

  WEBHOOK_URL=$(cat "$CREDENTIALS_DIRECTORY"/mc-ds-webhook)
  curl -sS -f --max-time 10 -o /dev/null -H "Content-Type: application/json" -d "$REQUEST" "$WEBHOOK_URL"
}

notify "$@"
