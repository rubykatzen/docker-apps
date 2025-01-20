#!/bin/bash
source servers.env
for server in "${SERVERS[@]}"
do
  echo "============================================="
  echo "update ${server}"
  echo "-->"
  # ToDo: push .env
  ssh -A "${server}" 'cd dapps; git pull'
  ssh -A "${server}" 'cd dapps; ./update.sh'
  ssh -A "${server}" 'cd dapps; docker rmi $(docker images -q) -f'
done
