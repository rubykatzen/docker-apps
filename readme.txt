docker network create traefik

docker compose -f ./traefik/docker-compose.yml logs -f
docker compose -f ./portainer/docker-compose.yml logs -f
