#!/bin/bash

docker-compose exec ksql-cli-east bash -c "ksql http://ksql-server-east:8089 <<EOF
RUN SCRIPT '/etc/kafka/demo/ksql-statement-2.sql';
exit ;
EOF
"

echo "\n===> Read from ksql-east cluster, topic stockapp-users-count..."

docker-compose exec kafka-connect-west kafka-avro-console-consumer \
         --bootstrap-server broker-east:19092 \
         --property schema.registry.url=http://schema-registry:8081 \
         --topic stockapp-users-count \
         --from-beginning \
         --consumer-property group.id=comsumer-east \
         --property print.key=true \
         --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer

