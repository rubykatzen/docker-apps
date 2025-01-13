#!/bin/bash
source apps.env
for app in "${DAPPS[@]}"
do
  docker compose --env-file ./apps/"${app}"/.env --env-file .env -f ./apps/"${app}"/docker-compose.yml pull
  docker compose --env-file ./apps/"${app}"/.env --env-file .env -f ./apps/"${app}"/docker-compose.yml up -d
done
