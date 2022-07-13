#!/bin/bash

echo -e "\n===>Create stockapp-users topic with 4 partitions ..."
docker-compose exec broker-west kafka-topics  --create --bootstrap-server broker-west:19091 --topic stockapp-users --partitions 4


