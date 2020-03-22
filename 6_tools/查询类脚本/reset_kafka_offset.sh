#!/bin/bash
#cmd_bin="/data/jtb/infra/kafka_2.12-2.2.0/bin"
#kafka_hosts="10.111.30.10:9092,10.111.30.5:9092,10.111.30.3:9092"
#
#for i in `seq 1 9`;do
#  cd ${cmd_bin} &&  \
#  ./kafka-consumer-groups.sh --execute --reset-offsets --bootstrap-server=${kafka_hosts}  --topic="loc_topic{i}" --group="testPlatform-loc{i}" --to-earliest
#done

for i in `seq 1 48`;do
   /data/jtb/infra/kafka_2.12-2.2.0/bin/kafka-consumer-groups.sh --execute --reset-offsets --bootstrap-server=10.111.30.10:9092,10.111.30.5:9092,10.111.30.3:9092 --topic=loc_topic${i} --group=testPlatform-loc${i} --to-earliest
done
