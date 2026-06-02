#!/bin/bash
set -e
source "$(dirname "$0")/lib.sh"
set -a
source .env
source apps.env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  apps=("${APPS[@]}")
fi

for app in "${apps[@]}"
do
  generate_env "${app}"
  docker compose -f "./apps/${app}/docker-compose.yml" down
done
