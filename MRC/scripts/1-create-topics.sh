#!/bin/bash

echo -e "\n===>Create stockapp-users topic with 4 partitions ..."
docker-compose exec broker-west-1 kafka-topics  --create --bootstrap-server broker-west-1:19091 --topic stockapp-users --partitions 4

docker-compose exec broker-west-1 kafka-topics  --create --bootstrap-server broker-west-1:19091 --topic stockapp-users-count --partitions 4


echo -e "\n===>List stock topics ..."
docker-compose  exec broker-west-1 kafka-topics --list --bootstrap-server broker-west-1:19091 | grep stockapp-users

echo -e "\n===>Set Replica placement for internal connect topics"

#for t in docker-kafka-connect-configs docker-kafka-connect-offsets docker-kafka-connect-status __consumer_offsets
for t in __consumer_offsets
  do 
    docker-compose exec broker-east-5 kafka-configs --bootstrap-server localhost:19095 --entity-name  $t --entity-type topics --alter --replica-placement /etc/kafka/demo/my-placement-mrc-sync-op.json
  done


docker-compose exec broker-east-5 confluent-rebalancer execute --bootstrap-server localhost:19095 --replica-placement-only --throttle 100000 --verbose --force 

for t in docker-kafka-connect-configs docker-kafka-connect-offsets docker-kafka-connect-status __consumer_offsets
  do 
    docker-compose exec broker-east-5 kafka-topics --describe --bootstrap-server localhost:19095 --topic $t
  done


