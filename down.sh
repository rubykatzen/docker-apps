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
  docker compose --env-file ./apps/"${app}"/.env --env-file .env -f ./apps/"${app}"/docker-compose.yml down
done
