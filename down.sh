#!/bin/bash

docker compose -f ./traefik/docker-compose.yml down
docker compose -f ./portainer/docker-compose.yml down
