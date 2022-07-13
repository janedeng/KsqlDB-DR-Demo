#! /bin/bash

echo -e "\n===> Read the stockapp-users-count from East Cluster"
docker-compose -f $DIR/docker-compose-east-connect.yaml exec kafka-connect-east kafka-avro-console-consumer \
          --bootstrap-server broker-east:19092 \
          --property schema.registry.url=http://schema-registry:8081 \
          --topic stockapp-users-count \
          --consumer-property group.id=comsumer-east \
          --property print.key=true \
          --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer
