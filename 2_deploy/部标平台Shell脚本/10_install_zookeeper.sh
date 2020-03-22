#!/bin/bash
rpm_path=/root/kafka_2.12-2.2.0.tgz
version="kafka_2.12-2.2.0"
#manage_user=admin
manager_root=/data/jtb/infra
log_dir=/data/jtb/logs/zookeeper
configfile=${manager_root}/${version}/config/zookeeper.properties
cmd=${manager_root}/${version}/bin/zookeeper-server-start.sh
#You need change datadir,datalogdir when execute this shell
datadir=${manager_root}/zookeeper/data
dataLogDir=${manager_root}/zookeeper/log
port=2181
ip=`ifconfig eth0|awk 'NR==2{print $2}'`
#Notice,you should add other zookeeper  ip  in variable like ip2,ip3
ip1=10.111.30.3
ip2=10.111.30.10
ip3=10.111.30.5
#Notice,you should modify number for zookeeper_data/myid ...
#number=1

#Tips,if you set up zookeeper,ans $USER is not root ,you need open this function chack_user.
#check_user () {
#  if id -u ${manage_user} > /dev/null 2>&1;then
#     echo "${manage_user} is exists"
#  else
#     echo "${manage_user} dose not exist"  && \
#     useradd ${manage_user} && \
#     chown -R $USER:$USER ${manager_root}/zookeeper
#     echo "${manage_user} add successful"
#  fi
#}

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

setting_zookeeper () {
  if [ ! -e ${manager_root}/zookeeper ]
  then
     mkdir ${manager_root}/zookeeper
     mkdir ${datadir}    
     mkdir ${dataLogDir}
  fi
  if [ ! -e ${log_dir} ]
  then
     mkdir ${log_dir}
  fi
  tar -xf ${rpm_path} -C ${manager_root}  &&  \
  cd ${manager_root}/${version}  && \
  cp -f ${configfile}  ${configfile}.bak && \
  sed -i 's/^/#/g' ${configfile}  && \
  echo "${number}" > ${datadir}/myid
  cat >> ${configfile} << EOF
maxClientCnxns=0
tickTime=2000
initLimit=10
syncLimit=5
clientPort=${port}
dataDir=${datadir}
dataLogDir=${dataLogDir}
server.1=${ip1}:2888:3888
server.2=${ip2}:2888:3888 
server.3=${ip3}:2888:3888
EOF
} 

#change owner admin of all dir
check_zookeeper () {
  #chown -R ${manage_user}:${manage_user} ${manager_root}/${version}  && \
  nohup ${cmd}  ${configfile} > ${log_dir}/zookeeper.log 2>&1 &
  sleep 3  && \ 
  ps -ef|grep -v grep |grep -w "zookeeper.properties" |grep -v `basename $0` 
  RETVAL=$? 
  if [ $RETVAL -eq 0 ];then
    echo -e  "\033[1;32mzoookeeper start successful\033[0m"
  else
    echo -e  "\033[1;31mzoookeeper start failed\033[0m"
  fi 
}

#check_user && \
check_ip && \
set_number && \
setting_zookeeper && \
check_zookeeper
