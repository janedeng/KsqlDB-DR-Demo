#! /bin/bash

echo -e "##################################################"
echo -e "# Ksql DR with MRC                               #"
echo -e "##################################################"

echo -e "\n===> Setting demo directory..."
export DIR=${PWD%/*}
echo -e "Demo Home = $DIR\n"

docker-nuke.sh
sleep 5

echo -e "\n===>Start cluster"
docker-compose up -d

sleep 50 # Give the cluster time to start up
$DIR/scripts/1-create-topics.sh

$DIR/scripts/2-create-datagen-trades-connector.sh

$DIR/scripts/3-run-ksql-west.sh

$DIR/scripts/4-stop-west.sh

$DIR/scripts/5-consume-from-east.sh



