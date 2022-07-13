#! /bin/bash

echo "\n===> Stop West region..."

docker-compose stop kafka-connect-west ksql-cli-west ksql-server-west broker-west zookeeper-west

sleep 20

docker-compose exec broker-east kafka-cluster-links \
        --bootstrap-server broker-east:19092 \
        --describe

docker-compose exec broker-west kafka-cluster-links \
        --bootstrap-server broker-west:19091 \
        --describe
