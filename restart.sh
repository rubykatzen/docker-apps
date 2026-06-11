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
  "$(dirname "$0")/down.sh" "$app"
  "$(dirname "$0")/up.sh" "$app"
done
