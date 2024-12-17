docker network create traefik
touch traefik/acme.json
chmod 600 traefik/acme.json

docker compose -f ./traefik/docker-compose.yml logs -f
