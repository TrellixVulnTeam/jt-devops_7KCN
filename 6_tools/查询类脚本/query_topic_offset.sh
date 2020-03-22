#!/bin/bash
cmd_bin=/data/jtb/infra/kafka_2.12-2.2.0/bin/kafka-consumer-groups.sh
kafka_hosts=10.111.30.8:9092,10.111.30.9:9092,10.111.30.4:9092
log=/root/kafka_offset_message.log
for i in `seq 1 48`;do
  if [ $i -eq 1 ];then
     ${cmd_bin}  --bootstrap-server=${kafka_hosts}  --group=testPlatform-locphg${i} --describe |sed -n '2,3p' > ${log}
  else
     ${cmd_bin}  --bootstrap-server=${kafka_hosts}  --group=testPlatform-locphg${i} --describe |sed -n '3p' >> ${log}
  fi
done
