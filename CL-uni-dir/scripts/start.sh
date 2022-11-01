#! /bin/bash

echo -e "##################################################"
echo -e "# Ksql DR with unidirectional Cluster Linking    #"
echo -e "##################################################"

echo -e "\n===> Setting demo directory..."
export DIR=${PWD%/*}
echo -e "Demo Home = $DIR\n"

$DIR/../utils/docker-nuke.sh

echo -e "\n===>Start cluster"
docker-compose up -d

sleep 50 # Give the cluster time to start up

$DIR/scripts/1-create-topics.sh

$DIR/scripts/2-create-links-mirror-topics.sh

$DIR/scripts/3-create-datagen-trades-connector.sh

$DIR/scripts/4-run-ksql-west.sh

$DIR/scripts/6-list-links-and-lag.sh

$DIR/scripts/7-stop-west.sh

$DIR/scripts/8-create-east-connector-resume-produce.sh

$DIR/scripts/9-read-user-count-from-east.sh


