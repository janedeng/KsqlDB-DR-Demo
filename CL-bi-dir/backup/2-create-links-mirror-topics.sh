#!/bin/bash


printf "=================================================\n"
printf "== Create West -> East link and mirror topics ==\n"
printf "=================================================\n"

docker-compose exec broker-east bash -c 'echo "{\"groupFilters\": [{\"name\": \"*\",\"patternType\": \"LITERAL\",\"filterType\": \"INCLUDE\"}]}" > groupFilters.json'
docker-compose exec broker-east kafka-cluster-links \
	--bootstrap-server broker-east:19092 \
	--create \
	--link west-2-east-stockuser-link \
	--config bootstrap.servers=broker-west:19091,consumer.offset.sync.enable=true,consumer.offset.sync.ms=10000 \
	--consumer-group-filters-json-file groupFilters.json

sleep 2

printf  "\n==> Create a mirror topic for stockapp-users-west on the east side\n"

docker-compose exec broker-east kafka-mirrors --create \
	--bootstrap-server broker-east:19092 \
	--mirror-topic stockapp-users-west \
	--link west-2-east-stockuser-link

printf "\n ==> Create mirrot topics for connect config topics ...\n"

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic west-kafka-connect-configs \
        --link west-2-east-stockuser-link

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic west-kafka-connect-offsets \
        --link west-2-east-stockuser-link

docker-compose exec broker-east kafka-mirrors --create \
        --bootstrap-server broker-east:19092 \
        --mirror-topic west-kafka-connect-status \
        --link west-2-east-stockuser-link


printf "=================================================\n"
printf "== Create East -> West link and mirror topics ==\n"
printf "=================================================\n"

docker-compose exec broker-west bash -c 'echo "{\"groupFilters\": [{\"name\": \"*\",\"patternType\": \"LITERAL\",\"filterType\": \"INCLUDE\"}]}" > groupFilters.json'
docker-compose exec broker-west kafka-cluster-links \
        --bootstrap-server broker-west:19091 \
        --create \
        --link east-2-west-stockuser-link \
        --config bootstrap.servers=broker-east:19092,consumer.offset.sync.enable=true,consumer.offset.sync.ms=10000 \
        --consumer-group-filters-json-file groupFilters.json


printf  "\n==> Create a mirror topic stockapp-users-east on the west side\n"

docker-compose exec broker-west kafka-mirrors --create \
        --bootstrap-server broker-west:19091 \
        --mirror-topic stockapp-users-east \
        --link east-2-west-stockuser-link

printf "\n ==> Create mirrot topics for connect config topics ...\n"

docker-compose exec broker-west kafka-mirrors --create \
        --bootstrap-server broker-west:19091 \
        --mirror-topic east-kafka-connect-configs \
        --link east-2-west-stockuser-link

docker-compose exec broker-west kafka-mirrors --create \
        --bootstrap-server broker-west:19091 \
        --mirror-topic east-kafka-connect-offsets \
        --link east-2-west-stockuser-link

docker-compose exec broker-west kafka-mirrors --create \
        --bootstrap-server broker-west:19091 \
        --mirror-topic east-kafka-connect-status \
        --link east-2-west-stockuser-link

printf "\n\nList topics on west side after mirroring...\n"
docker-compose  exec broker-west kafka-topics --list --bootstrap-server broker-west:19091 | grep -v "_confluent"

printf "\n\nList topics on east side after mirroring....\n"
docker-compose  exec broker-east kafka-topics --list --bootstrap-server broker-east:19092 | grep -v "_confluent"

