#!/bin/bash

docker compose --env-file .env -f ./traefik/docker-compose.yml down
docker compose --env-file .env -f ./portainer/docker-compose.yml down
docker compose --env-file .env -f ./whoami/docker-compose.yml down
docker compose --env-file .env -f ./beszel/docker-compose.yml down
