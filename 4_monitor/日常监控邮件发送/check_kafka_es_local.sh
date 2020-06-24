#!/bin/bash

home_dir=/data/infra/kafka_2.12-2.2.0/bin/
kafka_nodes=192.168.0.4:9092,192.168.0.2:9092,192.168.0.5:9092

es_node=192.168.0.2
port=9200
gateway_calc_forward_file=/tmp/forward.log
gateway_calc_trip_file=/tmp/trip.log
provider_terminal_file=/tmp/terminal.log
es_status_file=/tmp/es.log

check_kafka () {
 cd ${home_dir}  && \
 ./kafka-consumer-groups.sh  --bootstrap-server=${kafka_nodes} --group=gateway-calc-trip --describe > ${gateway_calc_trip_file}
 sed -i "1c Topic名称 分区编号 当前消耗offset 消息总量offset 待消耗消息数量 consumer名称  consumer实例(主机)  客户端ID" ${gateway_calc_trip_file}
 echo "Gateway-calc-trip 巡检时间 `date +'%F:%R'`" >> ${gateway_calc_trip_file}
 sleep 1
 ./kafka-consumer-groups.sh  --bootstrap-server=${kafka_nodes} --group=gateway-calc-forward --describe > ${gateway_calc_forward_file}
 sed -i "1c Topic名称 分区编号 当前消耗offset 消息总量offset 待消耗消息数量 consumer名称  consumer实例(主机)  客户端ID" ${gateway_calc_forward_file}
 echo "Gateway-calc-forward 巡检时间 `date +'%F:%R'`" >> ${gateway_calc_forward_file}
 sleep 1
 ./kafka-consumer-groups.sh  --bootstrap-server=${kafka_nodes} --group=testPlatform --describe > ${provider_terminal_file}
 sed -i "1c Topic名称 分区编号 当前消耗offset 消息总量offset 待消耗消息数量 consumer名称  consumer实例(主机)  客户端ID" ${provider_terminal_file}
 echo "Jt-platform-provider-terminal 巡检时间 `date +'%F:%R'`" >> ${provider_terminal_file}
}

check_es () {
   curl http://${es_node}:${port}/_cat/nodes?v > ${es_status_file}
   echo "Elasticsearch 集群状态如上 巡检时间 `date +'%F:%R'`" >> ${es_status_file}
}

main () {
  check_kafka
  check_es
}



main
