#!/bin/bash
set -e
set -a
source .env
source apps.env
set +a

if [ $# -gt 0 ]; then
  apps=("$@")
else
  apps=("${APPS[@]}")
fi

for app in "${apps[@]}"; do
  ./down.sh "$app"
  ./up.sh "$app"
done
