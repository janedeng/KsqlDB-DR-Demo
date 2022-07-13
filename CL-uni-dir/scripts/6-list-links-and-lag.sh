#!/bin/bash

echo -e "\n==> List cluster links\n"

docker-compose exec broker-east kafka-cluster-links \
	--bootstrap-server broker-east:19092 \
	--list

echo -e "\n==> Link Metrics"

for metric in MaxLag
do
    echo -e "\n==> Monitor $metric \n"

    for link in west-2-east-stocktrade-link
    do
        LAG=$(docker-compose exec broker-east kafka-run-class kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:8092/jmxrmi \
        --object-name kafka.server.link:type=ClusterLinkFetcherManager,name=$metric,clientId=ClusterLink,link-name=$link \
        --one-time true | tail -n 1 | awk -F, '{print $2;}' | head -c 1)
        echo "$link: $LAG"
    done

done

echo -e "\n===>Check consumer group status"
docker-compose  exec broker-east kafka-consumer-groups --bootstrap-server broker-east:19092 --group comsumer-east --describe

docker-compose  exec broker-west kafka-consumer-groups --bootstrap-server broker-west:19091 --group comsumer-west --describe

echo -e "\n===>List topics on west side ...\n"
docker-compose  exec broker-west kafka-topics --list --bootstrap-server broker-west:19091 | grep -v "_confluent"

echo -e "\n===>List topics on east side ....\n"
docker-compose  exec broker-east kafka-topics --list --bootstrap-server broker-east:19092 | grep -v "_confluent"
