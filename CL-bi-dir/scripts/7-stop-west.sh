#! /bin/bash

echo -e "\n===> Stop West region..."

docker-compose stop kafka-connect-west ksql-cli-west ksql-server-west broker-west zookeeper-west

sleep 20

echo -e "\n===> Describe mirror topics..."
docker-compose exec broker-east kafka-mirrors \
        --bootstrap-server broker-east:19092 \
        --link west-2-east-stockuser-link \
        --describe

docker-compose exec broker-west kafka-mirrors \
        --bootstrap-server broker-west:19091 \
        --link east-2-west-stockuser-link \
        --describe

echo -e "\n===> Failover the internal connect topics to the east cluster..."

docker-compose exec broker-east kafka-mirrors --failover \
  --topics docker-kafka-connect-configs,docker-kafka-connect-offsets,docker-kafka-connect-status \
  --bootstrap-server broker-east:19092

echo -e "\n===> check pending-stopped-only"
docker-compose exec broker-east kafka-mirrors  --pending-stopped-only  --bootstrap-server broker-east:19092 --topics docker-kafka-connect-configs,docker-kafka-connect-offsets,docker-kafka-connect-status --describe
