#!/bin/bash
Manager_root=/home/admin/kafka-manager-1.3.3.23
CMd=${Manager_root}/bin/kafka-manager
COnfigefile=${Manager_root}/conf/application.conf
Port=9107
#You need add all zk server ip and port in variable allzk,For example,"192.168.0.2:2181,192.168.0.5:2181,192.168.0.4:2181"
#allzk=" "
setting_kafka_manager () {
  cp ${COnfigefile} ${COnfigefile}.bak  && \
  sed -r -i "s;^(kafka-manager.zkhosts=)(localhost).*;\1${allzk};"
}

start_kafka_manager () {
  nohup  ${CMd} -Dhttp.port=$Port  > /dev/null 2>&1  &
  sleep 3 && \
  ps -ef |grep -v grep |grep -w "kafka-manager-1.3.3.23"  &> /dev/null
  if [ $? -eq 0 ];then
    echo "kafka-manager is start successful"
  else 
    echo "kafka-manager is start failed"
    exit
  fi
}

setting_kafka_manager && \
start_kafka_manager
