#!/bin/bash
source servers.env
for server in "${SERVERS[@]}"
do
  echo "============================================="
  echo "update ${server}"
  echo "-->"
  # ToDo: push .env
  ssh -A "${server}" 'cd docker-apps; git pull'
  ssh -A "${server}" 'cd docker-apps; ./update.sh'
  ssh -A "${server}" 'cd docker-apps; docker rmi $(docker images -q) -f'
done
