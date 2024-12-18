#!/bin/bash
source servers.env
for server in "${SERVERS[@]}"
do
  la -la
done
