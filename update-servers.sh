#!/bin/bash
source servers.env
for server in "${SERVERS[@]}"
do
  ssh -A "${server}" 'cd docker-apps; git pull'
  ssh -A "${server}" 'cd docker-apps; ./update.sh'
done
