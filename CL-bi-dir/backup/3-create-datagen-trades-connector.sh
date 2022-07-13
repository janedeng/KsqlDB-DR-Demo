#!/bin/bash

echo "Start datagen connector on the west cluster \n"
HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "stockapp-user-west",
  "config": {
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "stockapp-users-west",
    "quickstart": "Users_",
    "max.interval": 5000,
    "iterations": 1000
   }
}
EOF
)

docker-compose exec kafka-connect-west curl -X POST -H "${HEADER}" --data "${DATA}" http://kafka-connect-west:8083/connectors || exit 1 


#echo "Start datagen connector on the East cluster"
#HEADER2="Content-Type: application/json"
#DATA2=$( cat << EOF
#{
#  "name": "stockapp-user-east",
#  "config": {
#    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
#    "tasks.max": "1",
#    "kafka.topic": "stockapp-users-east",
#    "quickstart": "Users_",
#    "max.interval": 5000,
#    "iterations": 1000
#   }
#}
#EOF
#)
#docker-compose exec kafka-connect-east curl -X POST -H "${HEADER2}" --data "${DATA2}" http://kafka-connect-east:8084/connectors || exit 1
