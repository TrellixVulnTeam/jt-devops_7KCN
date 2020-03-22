#!/bin/bash
cmd_bin="/data/jtb/infra/kafka_2.12-2.2.0/bin"
zk_hosts="10.111.30.3:2181,10.111.30.10:2181,10.111.30.5:2181"

for i in `seq 1 10`;do
  cd ${cmd_bin}  && \
  ./kafka-topics.sh --delete --zookeeper ${zk_hosts} --topic loc_topic${i}
done
