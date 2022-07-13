#! /bin/bash


echo -e "\n===>Start east connect cluster"
docker-compose -f $DIR/docker-compose-east-connect.yaml up -d
sleep 50

echo $DIR/docker-compose-east-connect.yaml

echo -e "\n===>Check connector status"
docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east curl -X GET http://kafka-connect-east:8084/connectors?expand=status | jq

echo -e "\n===> Restart connector tasks"
docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east curl -X POST http://kafka-connect-east:8084/connectors/stockapp-trades-source/restart/?includeTasks=true

sleep 10

echo -e "\n===>Check connector status again"
docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east curl -X GET http://kafka-connect-east:8084/connectors/stockapp-trades-source/status | jq

