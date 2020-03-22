#!/bin/bash
rpm_path=/root/kibana-6.7.0-x86_64.rpm
config_path=/etc/kibana/kibana.yml
port=5601
ip=0.0.0.0
link_ip=`ifconfig eth0|awk -F '[ ]+' 'NR==2{print $3}'`
#need add one es_cluster ip,for example es_host=["http://192.168.0.2:9200"]
#es_host=["http://ip:port"]
#es_host=["http://10.111.30.3:9200"]
es_host=["http://${link_ip}:9200"]
echo "begin setup logstash..."
if [ -e ${rpm_path} ];then
   yum -y install ${rpm_path}
else 
   echo "kibana-6.7.0-x86_64.rpm is not exists"
   exit 1
fi
echo "begin setting kibanna..."
cp ${config_path}  ${config_path}.bak && \
sed -r -i "s;^(#)(server.port:).*;\2 ${port};" ${config_path}  && \
sed -r -i "s;^(#)(server.host:).*;\2 "${ip}";" ${config_path}  && \
sed -r -i "s;^(#)(elasticsearch.hosts:).*;\2 ${es_host};" ${config_path}  && \
sed -r -i "s;^(#)(elasticsearch.pingTimeout:).*;\2 1500;" ${config_path}  && \
sed -r -i "s;^(#)(elasticsearch.requestTimeout:).*;\2 30000;" ${config_path}  && \
sed -r -i "s;^(#)(elasticsearch.shardTimeout:).*;\2 20000;" ${config_path} && \
echo "kibana setting successful,you can start kibana"  && \
systemctl start kibana
if [ $? -eq 0 ];then
  echo "kibana setting successful" |tee -a ${log}
else 
  echo "kibana setting faild" |tee -a ${log}
fi
sleep 5
netstat -nutlp|grep ${port} &> /dev/null
if [ $? -eq 0 ];then
  echo -e "\033[1;32mkibana setup successful\033[0m" |tee -a ${log}
else
  echo -e "\033[1;31mkibana setup failed\033[0m" |tee -a ${log}
fi
systemctl enable kibana
