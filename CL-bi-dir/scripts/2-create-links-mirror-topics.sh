#!/bin/bash


echo -e "================================================="
echo -e "== Create West -> East link and mirror topics =="
echo -e "================================================="

docker-compose exec broker-east bash -c 'echo "{\"groupFilters\": [{\"name\": \"*\",\"patternType\": \"LITERAL\",\"filterType\": \"INCLUDE\"}]}" > groupFilters.json'
docker-compose exec broker-east kafka-cluster-links \
	--bootstrap-server broker-east:19092 \
	--create \
	--link west-2-east-stockuser-link \
	--config bootstrap.servers=broker-west:19091,consumer.offset.sync.enable=true,consumer.offset.sync.ms=10000 \
	--consumer-group-filters-json-file groupFilters.json

sleep 2

echo -e  "\n===> Create a mirror topic for stockapp-users-west on the east side\n"

docker-compose exec broker-east kafka-mirrors --create \
	--bootstrap-server broker-east:19092 \
	--mirror-topic stockapp-users-west \
	--link west-2-east-stockuser-link

echo -e "\n ===> Create mirrot topics for connect config topics ...\n"

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic docker-kafka-connect-configs \
        --link west-2-east-stockuser-link

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic docker-kafka-connect-offsets \
        --link west-2-east-stockuser-link

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic docker-kafka-connect-status \
        --link west-2-east-stockuser-link


echo -e "=================================================\n"
echo -e "== Create East -> West link and mirror topics ==\n"
echo -e "=================================================\n"

docker-compose exec broker-west bash -c 'echo "{\"groupFilters\": [{\"name\": \"*\",\"patternType\": \"LITERAL\",\"filterType\": \"INCLUDE\"}]}" > groupFilters.json'
docker-compose exec broker-west kafka-cluster-links \
        --bootstrap-server broker-west:19091 \
        --create \
        --link east-2-west-stockuser-link \
        --config bootstrap.servers=broker-east:19092,consumer.offset.sync.enable=true,consumer.offset.sync.ms=10000 \
        --consumer-group-filters-json-file groupFilters.json


echo -e  "\n==> Create a mirror topic stockapp-users-east on the west side\n"

docker-compose exec broker-west kafka-mirrors --create \
        --bootstrap-server broker-west:19091 \
        --mirror-topic stockapp-users-east \
        --link east-2-west-stockuser-link


echo -e "\n=== List topics on west side after mirroring...\n"
docker-compose  exec broker-west kafka-topics --list --bootstrap-server broker-west:19091 | grep -v "_confluent"

echo -e "\n===> List topics on east side after mirroring....\n"
docker-compose  exec broker-east kafka-topics --list --bootstrap-server broker-east:19092 | grep -v "_confluent"

