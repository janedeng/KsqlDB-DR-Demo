#! /bin/bash

echo -e "\n===> Stop West region..."

docker-compose stop kafka-connect-west ksql-cli-west ksql-server-west broker-west zookeeper-west

sleep 20

echo -e "\n===> Describe the mirror topic status..."
docker-compose exec broker-east kafka-mirrors --bootstrap-server broker-east:19092  --describe  --link west-2-east-stocktrade-link

echo -e "\n===> Failover the input topic stockapp_users in the East cluster..."

echo -e "\n===> Failover..."
docker-compose exec broker-east kafka-mirrors --failover \
  --topics stockapp-users,docker-kafka-connect-configs,docker-kafka-connect-offsets,docker-kafka-connect-status \
  --bootstrap-server broker-east:19092 

echo -e "\n ===> check pending-stopped-only"
docker-compose exec broker-east kafka-mirrors  --pending-stopped-only  --bootstrap-server broker-east:19092 --topics stockapp-users,docker-kafka-connect-configs,docker-kafka-connect-offsets docker-kafka-connect-status --describe
