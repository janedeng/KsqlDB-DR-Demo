# KsqlDB DR Demo


### NOTE: This repo is for demoing the DR scenarios purpose without testing completely. It's not ready for Production. 


Download the demo from github repo.

There are three scenarios included in this demo:

### 1. DR with uni-directional Cluster Linking.

#### Setup :
- The application topic is created in the Source cluster, and replicated to the DR cluster via Cluster Linking. 
- The internal connect topics (offsets, configs, and status) are also replicated from the Source cluster to the DR cluster via Cluster Linking. 
- The same set of Ksql statements are run on both Source and DR cluster.

#### DR:
If the source region is outage, 
- Failover the cluster links. 
- Launch the connector on the DR cluster with the same connect configuration. Also the same internal connect topics are used. 

#### How to run the script: 
1. cd {DemoHome}/CL-uni-dir/scripts
2. ./start.sh
3. When "Read from ksql-west cluster, topic stockapp-users-count", let the script run for a while.
4. Open a new window, run command: `scripts/5-run-ksql-east.sh`.

Observation: 
The count for each user are insync on both windows ( reading from the east and west cluster).

5. Ctrl C on both windows. The start.sh script will continue the next step.
6. The script will stop the west cluster and fail over to the east cluster. Then restart the connector.
7. The script continues, then "Read the stockapp-users-count from East Cluster"

Observation:
The count for each user are aggregated from the left over on the window of the east side in step 4 above. 

### 2. DR with bi-directional Cluster Linking

#### Setup:
- An application topic, e.g., stockapp-users-west is created in the source cluster, and replicated to the DR cluster. 
An application topic, stockapp-users-east, is created in the DR cluster, and replicated to the source cluster. 

- The internal connect topics (offsets, configs, and status) still need to be replicated from the source cluster to the DR clustervia uni-directional cluster linking. (The connectors need to use the same internal topics to resume the operations during DR.)

- The same set of Ksql statements are run on both source and DR cluster. In Ksql, we need to merge the data from the topic.west and topic.east, then use topic.aggregated to process. 

#### DR:
If the source region is outage,
- There is no need to failover the application topics (topic.west and topic.east). 
- It is still needed to failover the internal connect topics (connect configs, offsets and status) from the primary to DR cluster given the connector need to resume from the leftover. 
- The connector config needs to be modified to produce/consume to/from the topic in the local region. 


#### How to run the script:
1. cd {DemoHome}/CL-bi-dir/scripts
2. ./start.sh
3. At "Read from ksql-west cluster, topic stockapp-users-count", let the script run for a while.
4. Open a new window, run command: `scripts/5-run-ksql-east.sh`.

Observation:
The count for each user are insync on both windows ( reading from the east and west cluster).

5. Ctrl C on both windows. The start.sh script will continue the next step.
6. The script will stop the west cluster and fail over to the east cluster. Change the connector config to point the kafka topic from the west to the east, then restart the connector.
7. The script then "Read the stockapp-users-count from East Cluster"

Observation:
The count for each user are aggregated from the left over on the window of the east side in step 4 above. 

### 3. MRC:

#### Setup:
- A MRC cluster with two regions
- A connect strech cluster across two regions. (Depends on the network latency, the stretch cluster may or may not be better than relaunching the connect cluster in the DR site). 

#### DR:
- Failover is automatically. 

#### MRC Pre-requirement:
- network latency up to 50ms. Needs tuning if network latency  > 50ms and < 100ms.

#### How to run the script:
1. cd {DemoHome}/MRC/scripts:
2. ./start.sh
3. During step 4, "Read from ksql-west cluster, topic stockapp-users-count", let the script run for a while, then Ctrl C.
4. The script will continue to the next step. 
5. During step 5, "Read from ksql-east connect worker, topic stockapp-users-count", check the count per user id in step 4 and step 5. For each user, the count number should be aggregated. 
6. Ctrl C, the script will continue and print the consumer lag. The consumer lag will reduce after step 5.   


### Comparison:

#### Uni-directional Cluster Linking
We follow the recommendation in https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/dr-failover.html#recovery-recommendations-for-ksqldb-and-kstreams. This DR strategy is straight forward.

#### Bi-directional Cluster Linking
In this demo, since the producer is a source cluster, we need to maintain the same internal connect topics (connect configs, offsets and status) between the primary and the DR side. We can not fully utilize the advantage of the bi-directional Cluster Linking as we still need to fail over those internal connect topics. 

 Bi-directional Cluster Linking could be flexible when the producer is not a connector, but a Kafka client API. In that case, there is no need to break the cluster link during DR. 

 One reason we may choose bi-directional cluster linking in this demo case with the source connector as producers is: if processing the data in order isn't a concern, keeping the link active will at least recover any lagged data once the original cluster is back up and link is mirroring data again.

#### MRC:
Seamless Ksql failover during DR. 
The cost would be more replicas and disk usage in the clusters, inter-region network requests, more complicate cluster setup which need advance cluster management skill. MRC also has pre-requirement on network latency up to 50ms. 
