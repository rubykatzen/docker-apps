#!/bin/bash
cp .env.example .env
cp apps.env.example apps.env
mkdir apps-data
mkdir apps-data/traefik
touch apps-data/traefik/acme.json
chmod 600 apps-data/traefik/acme.json
docker network create traefik
docker network create databases
