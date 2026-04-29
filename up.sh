#!/bin/bash
set -e

ensure_file() {
  local source_file="$1"
  local target_file="$2"

  if [[ ! -f "$target_file" ]]; then
    cp "$source_file" "$target_file"
    echo "Created: $target_file"
  fi
}

ensure_network() {
  local network="$1"

  if ! docker network inspect "$network" >/dev/null 2>&1; then
    docker network create "$network" >/dev/null
    echo "Created Docker network: $network"
  fi
}

ensure_file .env.example .env
ensure_file apps.env.example apps.env
mkdir -p apps-data/traefik
touch apps-data/traefik/acme.json
chmod 600 apps-data/traefik/acme.json
ensure_network traefik
ensure_network databases
ensure_network mcp

set -a
source .env
source apps.env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  apps=("${DAPPS[@]}")
fi

for app in "${apps[@]}"
do
  (
    echo "Starting: ${app}"

    # Load app-specific env variables
    if [[ -f ./apps/"${app}"/.env ]]; then
      set -a
      source ./apps/"${app}"/.env
      set +a
    fi

    # Apply overrides from apps-data (take precedence over global env)
    if [[ -f ./apps-data/"${app}"/.env ]]; then
      set -a
      source ./apps-data/"${app}"/.env
      set +a
    fi

    # Create apps-data folder
    mkdir -p ./apps-data/"${app}"

    # Process all templates in config if the directory exists
    config_template_dir="./apps/${app}/config"
    config_dir="./apps-data/${app}/config"

    if [[ -d "$config_template_dir" ]]; then
      mkdir -p "$config_dir"
      for template in "$config_template_dir"/*.template.*; do
        # Check if file exists (to avoid error if no templates are found)
        [[ -e "$template" ]] || continue

        # remove .template from the filename
        filename="$(basename "$template")"
        filename="${filename/.template./.}"

        # Use envsubst
        envsubst < "$template" > "$config_dir/$filename"
        echo "Generated: $config_dir/$filename"
      done
    fi

    extra_env_file=()
    if [[ -f ./apps-data/"${app}"/.env ]]; then
      extra_env_file=(--env-file ./apps-data/"${app}"/.env)
    fi

    docker compose --env-file .env --env-file ./apps/"${app}"/.env "${extra_env_file[@]}" -f ./apps/"${app}"/docker-compose.yml pull
    docker compose --env-file .env --env-file ./apps/"${app}"/.env "${extra_env_file[@]}" -f ./apps/"${app}"/docker-compose.yml up -d --remove-orphans
  )
done

docker container prune -f
docker image prune -a -f
