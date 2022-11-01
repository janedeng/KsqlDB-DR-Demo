#!/usr/bin/env bash
echo "===="
echo "= Removing all docker containers"
echo "===="
docker rm -f $(docker ps -aq)

echo "===="
echo "= Removing unused containers, networks, dangling images"
echo "===="
docker system prune --volumes

