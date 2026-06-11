#!/bin/bash
validate_app_name() {
  local app

  app="$1"
  if [[ ! "$app" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    echo "Invalid app name: $app" >&2
    return 1
  fi
}

parse_apps() {
  local raw="${1:-}"
  local app
  local parsed_apps

  apps=()
  raw="${raw//$'\n'/,}"

  IFS=',' read -r -a parsed_apps <<< "$raw"
  for app in "${parsed_apps[@]}"; do
    app="${app#"${app%%[![:space:]]*}"}"
    app="${app%"${app##*[![:space:]]}"}"

    if [[ -z "$app" ]]; then
      echo "Invalid APPS value: empty app name in '$raw'" >&2
      return 1
    fi
    validate_app_name "$app" || return 1

    apps+=("$app")
  done

  if [[ ${#apps[@]} -eq 0 ]]; then
    echo "APPS must contain at least one app name" >&2
    return 1
  fi
}

require_app_compose() {
  local app="$1"

  validate_app_name "$app" || return 1

  if [[ ! -f "./apps/${app}/docker-compose.yml" ]]; then
    echo "Missing compose file for app: ./apps/${app}/docker-compose.yml" >&2
    return 1
  fi
}

