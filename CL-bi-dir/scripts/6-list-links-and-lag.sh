#!/bin/bash

echo -e "\n==> List cluster links\n"

docker-compose exec broker-east kafka-cluster-links \
	--bootstrap-server broker-east:19092 \
	--list

docker-compose exec broker-west kafka-cluster-links \
        --bootstrap-server broker-west:19091 \
        --list

echo -e "\n==> Link Metrics\n"

for metric in MaxLag
do
    echo -e "\n==> Monitor $metric \n"

    for link in west-2-east-stockuser-link east-2-west-stockuser-link 
    do
        LAG=$(docker-compose exec broker-east kafka-run-class kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:8092/jmxrmi \
        --object-name kafka.server.link:type=ClusterLinkFetcherManager,name=$metric,clientId=ClusterLink,link-name=$link \
        --one-time true | tail -n 1 | awk -F, '{print $2;}' | head -c 1)
        echo "$link: $LAG"
    done

done
