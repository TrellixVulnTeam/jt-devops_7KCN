#!/bin/bash
rpm_path=/root/logstash-6.7.0.rpm
#If you change data_path,then you need modify it
data_path=/data/jtb/infra/logstash
#If you change log_path,then you need modify it
log_path=/data/jtb/infra/logstash
user=logstash
config_path=/etc/logstash/logstash.yml
ip=`ifconfig eth0 |awk 'NR==2{print $2}'`
PORT1=9250
PORT2=4567
#Notice:you need list logstash cluster ip in $allip,for exmaple ["es1.zhkj.com:9200","es2.zhkj.com:9200","es3.zhkj.com:9200"]
#allhost="[ ]"
allhost='["10.111.30.3:9200","10.111.30.10:9200","10.111.30.5:9200"]'
if [ -z $ip ];then
  echo "ip is null,please get ip" 
  exit 2
fi
which java > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo "Java enviroment is not set yet.."
  exit 6
fi
for port in ${PORT1} ${PORT2}
do
netstat -tnulp|grep ${port} > /dev/null
  if [ $? -eq 0 ];then
    echo "${port} is using,please change another one port.."
    exit 3
  fi
done
echo "mkdir and touch setup path..." |tee -a $log
if [ ! -d ${data_path} ];then  
   mkdir -p ${data_path} && \
   id ${user} > /dev/null 2>&1
   if [ $? -ne 0 ];then
       useradd ${user}  && \
       chown $user:$user ${data_path}
   fi 
fi
if [ ! -d ${log_path} ];then
   mkdir -p ${log_path} && \
   chown $user:$user ${log_path}
fi
echo "begin setup logstash..."
yum -y install ${rpm_path}
if [ $? -eq 0 ];then
   echo "logstash setup successful"
else  
   exit 4
fi
echo "begin setting logstash..."
cp -f ${config_path}   ${config_path}.bak  && \
sed -r -i "s;^(path.data:).*;\1 ${data_path};"  ${config_path}  && \
sed -r -i "s;^(path.logs:).*;\1 ${log_path};" ${config_path}   && \
sed -r -i "s;^(# )(http.host:).*;\2 "$ip";"  ${config_path}  && \
echo "settting logstash successful"
echo "begin setting input filter output policy..."
{ cat > /etc/logstash/conf.d/jtb.conf  << EOF
input  {
  tcp {
    mode => "server"
    host => "logstash.zhkj.com"
    port => ${PORT1}
    codec => "json"
  }
  gelf {
    host => "logstash.zhkj.com"
    port => ${PORT2}
    use_tcp => true
  }
}
filter {
  #Only matched data are send to output.
}
output {
  elasticsearch {
    action => "index"          #The operation on ES
    hosts  => ${allhost} #ElasticSearch host, can be array.
    index  => "jtb-applog-%{+YYYY.MM.dd}"         #The index to write data to.
  }
}
EOF
} && \
systemctl start logstash
sleep 3
ps -ef|grep -v grep |grep logstash|grep -v `basename $0`
if [ $? -eq 0 ];then
  echo -e "\033[1;32mlogstash is start successful\033[0m"
else
  echo -e "\033[1;31mlogstash is start faild\033[0m"
fi
systemctl enable logstash
