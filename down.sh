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

for app in "${apps[@]}"
do
  require_app_compose "${app}"
  "$(dirname "$0")/generate-env.sh" "${app}"
  set -a
  source "./apps/${app}/.env"
  set +a
  docker compose -f "./apps/${app}/docker-compose.yml" down
done
