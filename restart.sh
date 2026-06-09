#!/bin/bash
set -e
source "$(dirname "$0")/lib.sh"
set -a
source .env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  parse_apps "$APPS"
fi

for app in "${apps[@]}"; do
  require_app_compose "${app}"
  # Skip apps whose lifecycle is managed by Watchtower (com.centurylinklabs.watchtower.enable=true label)
  if grep -q 'com.centurylinklabs.watchtower.enable=true' "./apps/${app}/docker-compose.yml" 2>/dev/null; then
    echo "Skipping ${app} — managed by Watchtower"
    continue
  fi
  ./down.sh "$app"
  ./up.sh "$app"
done
