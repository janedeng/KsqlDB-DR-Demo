#!/bin/bash


echo -e "\n===> Read from ksql-east connect worker, topic stockapp-users-count..."

docker-compose exec kafka-connect-east kafka-avro-console-consumer \
         --bootstrap-server broker-east-5:19095 \
         --property schema.registry.url=http://schema-registry:8081 \
         --topic stockapp-users-count \
         --consumer-property group.id=avro-consumer \
         --property print.key=true \
         --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer


echo -e "\n===> Check consumer group offset for the avro console consumer again..."

docker-compose exec broker-east-5 kafka-consumer-groups --bootstrap-server localhost:19095 --describe --group avro-consumer
