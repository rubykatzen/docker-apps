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
  generate_env "${app}"
  echo "Generated env: ${app}"
done
