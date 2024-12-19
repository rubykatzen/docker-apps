#!/bin/bash
source servers.env
for server in "${SERVERS[@]}"
do
  echo "============================================="
  echo "update ${server}"
  echo "-->"
  ssh -A "${server}" 'cd docker-apps; git pull'
  ssh -A "${server}" 'cd docker-apps; ./update.sh'
  ssh -A "${server}" 'cd docker-apps; docker image prune'
done
