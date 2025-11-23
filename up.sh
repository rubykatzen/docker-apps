#!/bin/bash
set -e
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
  echo "Starting: ${app}"

  # Load app-specific env variables
  if [[ -f ./apps/"${app}"/.env ]]; then
    set -a
    source ./apps/"${app}"/.env
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

  docker compose --env-file ./apps/"${app}"/.env --env-file .env -f ./apps/"${app}"/docker-compose.yml pull
  docker compose --env-file ./apps/"${app}"/.env --env-file .env -f ./apps/"${app}"/docker-compose.yml up -d --remove-orphans
done

docker container prune -f
docker image prune -a -f
