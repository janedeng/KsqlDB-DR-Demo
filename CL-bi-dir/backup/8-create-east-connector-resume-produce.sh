#! /bin/bash

echo "Start the west datagen connector on the East side, resume producing from left over..."
docker-compose -f /Users/jadeng/test/ksql-HA-demo/docker-compose-east-connect.yaml up -d
sleep 20


