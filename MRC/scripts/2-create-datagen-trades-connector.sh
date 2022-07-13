#!/bin/bash

echo -e "\n===> Deploy Source connector"
HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "stockapp-trades-source",
  "config": {
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "2",
    "kafka.topic": "stockapp-users",
    "quickstart": "Users_",
    "max.interval": 5000,
    "iterations": 5000
   }
}
EOF
)

docker-compose exec kafka-connect-west curl -X POST -H "${HEADER}" --data "${DATA}" http://kafka-connect-west:8083/connectors || exit 1 

