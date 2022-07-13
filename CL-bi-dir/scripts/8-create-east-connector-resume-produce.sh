#! /bin/bash

echo -e "\n===>Start east connect cluster"
docker-compose -f $DIR/docker-compose-east-connect.yaml up -d
sleep 50

echo -e "\n===>Start the west datagen connector on the East side, resume producing from left over..."
HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "stockapp-users-east",
    "quickstart": "Users_",
    "max.interval": 5000,
    "iterations": 1000
}
EOF
)
docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east curl -X PUT -H "${HEADER}" --data "${DATA}" http://kafka-connect-east:8084/connectors/stockapp-user/config 

docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east curl -X POST http://kafka-connect-east:8084/connectors/stockapp-user/restart/?includeTasks=true

sleep 10

docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east curl -X GET http://kafka-connect-east:8084/connectors/stockapp-user/status | jq
