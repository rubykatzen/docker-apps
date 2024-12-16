#!/bin/bash

docker compose --env-file .env -f ./traefik/docker-compose.yml up -d
docker compose --env-file .env -f ./portainer/docker-compose.yml up -d
docker compose --env-file .env -f ./whoami/docker-compose.yml up -d
