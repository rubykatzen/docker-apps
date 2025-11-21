docker network create traefik
docker network create databases

touch traefik/acme.json
chmod 600 traefik/acme.json

docker compose -f ./apps/traefik/docker-compose.yml logs -f
