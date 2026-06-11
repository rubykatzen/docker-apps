#!/bin/bash
set -e
source "$(dirname "$0")/lib.sh"
set -a
source .env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  parse_apps "$APPS"
fi

for app in "${apps[@]}"; do
  require_app_compose "${app}"
  output="./apps/${app}/.env"
  {
    cat .env
    echo "APP_NAME=${app}"
  } | awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    /=/ {
      key = substr($0, 1, index($0, "=") - 1)
      vals[key] = $0
      if (!(key in seen)) { order[++n] = key; seen[key] = 1 }
    }
    END { for (i = 1; i <= n; i++) print vals[order[i]] }
  ' | { echo "# Auto-generated — do not edit. Use ./generate-env.sh to regenerate."; cat; } > "$output"
  echo "Generated env: ${app}"
done
