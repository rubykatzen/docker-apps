#!/bin/bash
set -e
set -a
source .env
source apps.env
set +a

if [ $# -eq 1 ]; then
  app="$1"
else
  echo "Usage: $0 <app_name>"
  echo "Available apps: ${DAPPS[*]}"
  exit 1
fi

docker compose --env-file ./apps/"${app}"/.env --env-file .env -f ./apps/"${app}"/docker-compose.yml logs -f
