#!/bin/bash
cp .env.example .env
cp apps.env.example apps.env
touch traefik/acme.json
chmod 600 traefik/acme.json
docker network create traefik
