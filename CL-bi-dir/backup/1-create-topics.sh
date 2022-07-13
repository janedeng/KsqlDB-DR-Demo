#!/bin/bash

echo "Create stockapp-users-<region> topic with 4 partitions ..."
docker-compose exec broker-west kafka-topics  --create --bootstrap-server broker-west:19091 --topic stockapp-users-west --partitions 4

docker-compose exec broker-east kafka-topics  --create --bootstrap-server broker-east:19092 --topic stockapp-users-east --partitions 4


printf "\n\nList topics on west side ...\n"
docker-compose  exec broker-west kafka-topics --list --bootstrap-server broker-west:19091 | grep -v "_confluent"

printf "\n\nList topics on east side ....\n"
docker-compose  exec broker-east kafka-topics --list --bootstrap-server broker-east:19092 | grep -v "_confluent"

