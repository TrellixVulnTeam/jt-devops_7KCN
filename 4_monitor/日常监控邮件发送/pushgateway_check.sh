#!/bin/bash

home_dir=/data/jtb/infra/kafka_2.12-2.2.0/bin/
kafka_nodes=192.168.1.5:9092,192.168.1.6:9092,192.168.1.7:9092
loc_log=/tmp/loc.log

push_ip=112.33.33.37
port=9093


forward_prod () {
    name=$2
    ./kafka-consumer-groups.sh --bootstrap-server=${kafka_nodes} --group=$1 --describe > ${loc_log}
    fun
}

forward_jg () {
    name=$2
    ./kafka-consumer-groups.sh --bootstrap-server=${kafka_nodes} --group=$1 --describe > ${loc_log} 
    fun
}

forward_test () {
    name=$2
    ./kafka-consumer-groups.sh --bootstrap-server=${kafka_nodes} --group=$1 --describe > ${loc_log} 
    fun
}

fun () {
    Loc0=`grep loc ${loc_log} |awk '$2==0{print $5}'`
    Loc1=`grep loc ${loc_log} |awk '$2==1{print $5}'`
    Loc2=`grep loc ${loc_log} |awk '$2==2{print $5}'`
    Loc3=`grep loc ${loc_log} |awk '$2==3{print $5}'`
    Loc4=`grep loc ${loc_log} |awk '$2==4{print $5}'`
    echo "${name} ${Loc0}" | curl --data-binary @- http://${push_ip}:${port}/metrics/job/Gateway-calc-forward/instance/loc0
    echo "${name} ${Loc1}" | curl --data-binary @- http://${push_ip}:${port}/metrics/job/Gateway-calc-forward/instance/loc1
    echo "${name} ${Loc2}" | curl --data-binary @- http://${push_ip}:${port}/metrics/job/Gateway-calc-forward/instance/loc2
    echo "${name} ${Loc3}" | curl --data-binary @- http://${push_ip}:${port}/metrics/job/Gateway-calc-forward/instance/loc3
    echo "${name} ${Loc4}" | curl --data-binary @- http://${push_ip}:${port}/metrics/job/Gateway-calc-forward/instance/loc4
}



main  () {
    cd ${home_dir}
    forward_prod  gateway-calc-forward-forward-instance-001  YG_forward_consume
    forward_jg    gateway-calc-forward-forward-jg-instance-001  JG_forward_consume
    forward_test  gateway-calc-forward-forward-test-instance-001  TEST_forward_consume
}


main
