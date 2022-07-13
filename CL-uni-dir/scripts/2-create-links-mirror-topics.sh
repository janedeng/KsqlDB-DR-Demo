#!/bin/bash


echo -e "\n==> Create West -> East link"
docker-compose exec broker-east bash -c 'echo "{\"groupFilters\": [{\"name\": \"*\",\"patternType\": \"LITERAL\",\"filterType\": \"INCLUDE\"}]}" > groupFilters.json'
docker-compose exec broker-east kafka-cluster-links \
	--bootstrap-server broker-east:19092 \
	--create \
	--link west-2-east-stocktrade-link \
	--config bootstrap.servers=broker-west:19091,consumer.offset.sync.enable=true,consumer.offset.sync.ms=10000 \
	--consumer-group-filters-json-file groupFilters.json

sleep 2

echo -e "\n==> Create an east mirror of west stockapp-users"

docker-compose exec broker-east kafka-mirrors --create \
	--bootstrap-server broker-east:19092 \
	--mirror-topic stockapp-users \
	--link west-2-east-stocktrade-link

echo -e "\n ==> Create mirror topics for connect config topics ..."

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic docker-kafka-connect-configs \
        --link west-2-east-stocktrade-link

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic docker-kafka-connect-offsets \
        --link west-2-east-stocktrade-link

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic docker-kafka-connect-status \
        --link west-2-east-stocktrade-link
