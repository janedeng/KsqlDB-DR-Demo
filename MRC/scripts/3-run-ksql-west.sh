#!/bin/bash

echo -e "\n===>Run Ksql statement"
docker-compose exec ksql-cli-west bash -c "ksql http://ksql-server-west:8088 <<EOF
RUN SCRIPT '/etc/kafka/demo/ksql-statement.sql';
exit ;
EOF
"

echo -e "\n===> Read from ksql-west cluster, topic stockapp-users-count..."
docker-compose exec kafka-connect-west kafka-avro-console-consumer \
         --bootstrap-server broker-west-1:19091 \
         --property schema.registry.url=http://schema-registry:8081 \
         --topic stockapp-users-count \
         --from-beginning \
         --consumer-property group.id=avro-consumer \
         --property print.key=true \
         --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer

