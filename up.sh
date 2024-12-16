#!/bin/bash
source apps.env
for app in "${APPS[@]}"
do
  docker compose --env-file .env -f ./"${app}"/docker-compose.yml up -d
done
