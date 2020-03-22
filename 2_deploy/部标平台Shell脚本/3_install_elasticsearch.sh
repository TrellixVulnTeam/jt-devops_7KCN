#!/bin/bash
es_rpm=/root/elasticsearch-6.7.0.rpm
user=elasticsearch
config_file=/etc/elasticsearch/elasticsearch.yml
Hostname=$(hostname)
cluster_name=my-application
ip=`ifconfig eth0|awk 'NR==2{print $2}'`
#need modify this path and change owner of this dir
setup_path=/data/jtb/infra/es
es_datadir=${setup_path}/data
es_logdir=${setup_path}/log
es_port=9200
name=`basename $0`
#you need add es-cluster all ip in ${allip},example ["192.168.0.2", "192.168.0.4", "192.168.0.5"]
allip="["10.111.30.5", "10.111.30.10", "10.111.30.3"]"
echo "mkdir setup path.." 
[ -f $log ] || touch $log
RESULT=`which java`
if [ -z ${RESULT} ];then
  echo "You need to setting java enviroment before execute this shell script"
fi

if [ -z $ip ];then
  echo "You must first get ip"
fi

if [ ! -e ${setup_path} ];then
   mkdir -p ${setup_path} && \
   mkdir ${es_datadir}  && \
   mkdir ${es_logdir}   && \
   id ${user} > /dev/null 2>&1 
   if [ $? -ne 0 ];then
      useradd ${user} 
   fi 
   chown -R $user:$user ${setup_path}
fi 
echo "setup es_rpm..."
  rpm -ivh  ${es_rpm} 

if [ $? -eq 0 ];then
  echo "es_rpm setup succes_ful"
else
 echo "es_rpm setup failed"
  exit 1
fi
echo "modify es_configuration..."
 cp -f ${config_file}  ${config_file}.bak && \
 sed -r -i "s;^(#)(cluster.name:).*;\2 ${cluster_name};" ${config_file}  && \
 sed -r -i "s;^(#)(node.name:).*;\2 ${Hostname};" ${config_file}  && \
 sed -r -i "s;^(path.data:).*;\1 ${es_datadir};" ${config_file} && \
 sed -r -i "s;^(path.logs:).*;\1 ${es_logdir};" ${config_file} && \
 sed -r -i "s;^(#)(network.host:).*;\2 $ip;"  ${config_file} && \
 sed -r -i "s;^(#)(http.port:).*;\2 ${es_port};" ${config_file} && \
 sed -r -i "s;^(#)(discovery.zen.ping.unicast.hosts:).*;\2 $allip;" ${config_file} && \
 chown -R ${user}:${user} ${setup_path}
echo "es_configuration setting successful"
echo "begin start elasticsearch..."
 systemctl start elasticsearch
sleep 5  
ps -ef|grep -v grep |grep ${user} |grep -v ${name}  &> /dev/null
if [ $? -eq 0 ];then 
 echo -e "\033[1;32melasticsearch start succesful\033[0m"
else
  echo -e "\033[1;31melasticsearch start failed\033[0m"
fi 
systemctl enable elasticsearch
