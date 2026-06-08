#!/bin/bash
set -e
set -a
source .env
source apps.env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  apps=("${APPS[@]}")
fi

for app in "${apps[@]}"; do
  # Skip apps whose lifecycle is managed by Watchtower (com.centurylinklabs.watchtower.enable=true label)
  if grep -q 'com.centurylinklabs.watchtower.enable=true' "./apps/${app}/docker-compose.yml" 2>/dev/null; then
    echo "Skipping ${app} — managed by Watchtower"
    continue
  fi
  ./down.sh "$app"
  ./up.sh "$app"
done
