#! /bin/bash

echo -e "\n===>Check connector status"

docker-compose exec kafka-connect-east curl -X GET http://kafka-connect-east:8084/connectors/stockapp-trades-source/status | jq

echo -e "\n===> Stop West region..."

docker-compose stop kafka-connect-west ksql-cli-west ksql-server-west broker-west-1 broker-west-2 broker-west-4 zookeeper-west

sleep 20

docker-compose ps

#echo -e "\n ===> Restart the connector"
#echo -e "\n ===> the connector and tasks should be able to fail over to the running worker node automatically.
#echo -e "\n ===> this step is optional, which forces the connector to restart and failover to reduce the wait time in demo"
#docker-compose exec kafka-connect-east curl -X POST http://kafka-connect-east:8084/connectors/stockapp-trades-source/restart/?includeTasks=true

sleep 10


echo -e "\n===> Check consumer group offset for the avro console consumer ..."

docker-compose exec broker-east-5 kafka-consumer-groups --bootstrap-server localhost:19095 --describe --group avro-consumer

echo -e "\n===> Check connect worker status ..."

docker-compose exec kafka-connect-east curl -X GET http://kafka-connect-east:8084/connectors/stockapp-trades-source/status | jq
