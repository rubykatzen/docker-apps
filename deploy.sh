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

"$(dirname "$0")/generate-env.sh" "${apps[@]}"

for app in "${apps[@]}"; do
  require_app_compose "${app}"
  if grep -q 'com.centurylinklabs.watchtower.enable=true' "./apps/${app}/docker-compose.yml" 2>/dev/null; then
    echo "Skipping restart: ${app} (managed by Watchtower, env regenerated)"
    continue
  fi
  "$(dirname "$0")/restart.sh" "$app"
done
