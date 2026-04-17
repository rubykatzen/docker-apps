#!/bin/bash
set -e
set -a
source .env
source apps.env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  apps=("${DAPPS[@]}")
fi

for app in "${apps[@]}"
do
  extra_env_file=()
  if [[ -f ./apps-data/"${app}"/.env ]]; then
    extra_env_file=(--env-file ./apps-data/"${app}"/.env)
  fi
  docker compose --env-file .env --env-file ./apps/"${app}"/.env "${extra_env_file[@]}" -f ./apps/"${app}"/docker-compose.yml down
done
