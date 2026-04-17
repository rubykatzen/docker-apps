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

extra_env_file=()
if [[ -f ./apps-data/"${app}"/.env ]]; then
  extra_env_file=(--env-file ./apps-data/"${app}"/.env)
fi
docker compose --env-file .env --env-file ./apps/"${app}"/.env "${extra_env_file[@]}" -f ./apps/"${app}"/docker-compose.yml logs -f
