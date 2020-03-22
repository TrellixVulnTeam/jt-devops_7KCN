#!/bin/bash
#Notice:Before execute this shell scirpt,you need ensure install_zookeeper script execute right.
#In this shell script,you also need modify some variables like ip,number and so on...
version="kafka_2.12-2.2.0"
manager_root=/data/jtb/infra
Configfile=${manager_root}/${version}/config/server.properties
Cmd=${manager_root}/${version}/bin/kafka-server-start.sh
Log_dirs=${manager_root}/kafka
log_dir=/data/jtb/logs/kafka
ip=`ifconfig eth0|awk 'NR==2{print $2}'`
Port=9092
#You need write all zookeeper server ip and port in variable iplist.For example:192.168.0.2:2181,192.168.0.4:2181,192.168.0.5:2181
iplist="10.111.30.3:2181,10.111.30.10:2181,10.111.30.5:2181"
#Notice if need to modify this number in different server.
#Number=3
ip1=10.111.30.3
ip2=10.111.30.10
ip3=10.111.30.5

check_ip () {
  if [ -z  $ip ];then
     echo "ip addr is null,please get ip first"
     exit 2
  else
     ping -c 3 ${ip} > /dev/null 2>&1
     result=$?
     if [ ${result} -ne 0 ];then
       echo "Maybe you need ensure ip first,make sure ip is right or no"
       exit 4
     fi
  fi
}


set_number () {
   if [ ${ip} == "${ip1}" ];then
      number=1
   elif [ ${ip} == "${ip2}" ];then
      number=2
   else
      number=3
   fi
}


setting_kafka () {
  if [ ! -e ${manager_root}/kafka ]
  then
     mkdir ${manager_root}/kafka
  fi
  if [ ! -e ${log_dir} ]
  then
     mkdir ${log_dir}
  fi
  cp ${Configfile}  ${Configfile}.bak  && \
  sed -r -i "s;^(broker.id=).*;\1${number};"  ${Configfile}   && \
  sed -r -i "s;^(#)(listeners=PLAINTEXT://).*;\2${ip}:${Port};"  ${Configfile}   && \
  sed -r -i "s;^(log.dirs=);\1${Log_dirs};" ${Configfile}   && \
  sed -r -i "s;^(zookeeper.connect=).*;\1${iplist};"  ${Configfile}  && \
  echo "zookeeper setting successful"
}

check_kafka () {
  nohup ${Cmd} ${Configfile} > ${log_dir}/kafka.log  2>&1 &
  sleep 3 && \
  ps -ef|grep -v grep |grep -w "server.properties" |grep -v `basename $0` &> /dev/null
  retval=$?
  if [ $retval -eq 0 ];then 
     echo "kafka server is start successful"
  else 
     echo "kafka server is start failed"
  fi
}

check_ip && \
set_number  && \
setting_kafka && \
check_kafka
