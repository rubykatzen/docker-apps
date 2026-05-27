#!/bin/bash
generate_env() {
  local app="$1"
  local output="./apps/${app}/.env"
  {
    cat .env
    [[ -f "apps.env" ]] && { echo; cat apps.env; }
    [[ -f "./apps/${app}/.env.base" ]] && { echo; cat "./apps/${app}/.env.base"; }
    [[ -f "./apps-data/${app}/.env" ]] && { echo; cat "./apps-data/${app}/.env"; }
  } | awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    /=/ {
      key = substr($0, 1, index($0, "=") - 1)
      vals[key] = $0
      if (!(key in seen)) { order[++n] = key; seen[key] = 1 }
    }
    END { for (i = 1; i <= n; i++) print vals[order[i]] }
  ' > "$output"
}
