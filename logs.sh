#!/bin/bash
set -e
source "$(dirname "$0")/lib.sh"
set -a
source .env
source apps.env
set +a

if [ $# -eq 1 ]; then
  app="$1"
else
  echo "Usage: $0 <app_name>"
  echo "Available apps: ${APPS[*]}"
  exit 1
fi

generate_env "${app}"
set -a
source "./apps/${app}/.env"
set +a
docker compose -f "./apps/${app}/docker-compose.yml" logs -f
