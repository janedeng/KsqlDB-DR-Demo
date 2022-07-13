#!/bin/bash

echo -e "\n===>Create stockapp-users-<region> topic with 4 partitions ..."
docker-compose exec broker-west kafka-topics  --create --bootstrap-server broker-west:19091 --topic stockapp-users-west --partitions 4

docker-compose exec broker-east kafka-topics  --create --bootstrap-server broker-east:19092 --topic stockapp-users-east --partitions 4


echo -e "\n===>List topics on west side ..."
docker-compose  exec broker-west kafka-topics --list --bootstrap-server broker-west:19091 | grep -v "_confluent"

echo -e "\n===>List topics on east side ...."
docker-compose  exec broker-east kafka-topics --list --bootstrap-server broker-east:19092 | grep -v "_confluent"

