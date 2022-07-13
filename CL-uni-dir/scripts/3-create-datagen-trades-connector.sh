#!/bin/bash

HEADER="Content-Type: application/json"

echo -e "\n===>Register Schema before starting the source connector...\n"

SCHEMA=$( cat << EOF
{"schema": "{\"type\":\"record\",\"name\":\"users\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"registertime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"regionid\",\"type\":\"string\"},{\"name\":\"gender\",\"type\":\"string\"},{\"name\":\"interests\",\"type\":{\"type\":\"array\",\"items\":\"string\"}},{\"name\":\"contactinfo\",\"type\":{\"type\":\"map\",\"values\":\"string\"}}],\"connect.name\":\"ksql.users\"}","schemaType": "AVRO"}
EOF
)

docker-compose exec schema-registry curl -X POST --data "${SCHEMA}" -H "${HEADER}" http://localhost:8081/subjects/stockapp-users-value/versions

echo -e "\n===>Create datagen source connector"
DATA=$( cat << EOF
{
  "name": "stockapp-trades-source",
  "config": {
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "stockapp-users",
    "quickstart": "Users_",
    "max.interval": 5000,
    "iterations": 1000
   }
}
EOF
)

docker-compose exec kafka-connect-west curl -X POST -H "${HEADER}" --data "${DATA}" http://kafka-connect-west:8083/connectors || exit 1 

