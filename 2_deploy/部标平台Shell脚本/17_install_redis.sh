#!/bin/bash
rpm=/root/redis-5.0.5.tar.gz
path=`echo ${rpm} |awk '{print substr($1,1,length($1)-7) }'`
ROOT_PATH=/data/jtb/infra/redis-5.0.5
configfile=${ROOT_PATH}/redis.conf
ip=`ifconfig eth0 |awk 'NR==2{print $2}'`
pass=haM7axfAIrQevA
REDISPORT=6379
dir=${ROOT_PATH}/data
policy=volatile-ttl
#pidfile=/var/run/redis_6379.pid
pidfile=${ROOT_PATH}/redis_6379.pid
cmd=/etc/init.d/redis

setup_dependrpm () {
yum -y install gcc tcl expect && \ 
tar -xf ${rpm}  && cp -r  ${path} /data/jtb/infra  && \
cd   ${ROOT_PATH} && \
make && make install && \
which expect
if [ $? -ne  0 ];then
   echo "expect cmd is setup faild" 
   exit 1
fi
if [ ! -e ${dir} ];then
  mkdir -p ${dir}
fi
}

#[ -f $pidfile ] && rm -f ${pidfile}
config_redis () {
  echo "Begin config redis..."
{ expect << EOF
spawn sh ${ROOT_PATH}/utils/install_server.sh
expect "redis port"  {send "${REDISPORT}\n"}
expect "/etc/redis/6379.conf"  {send "${ROOT_PATH}/redis.conf\n"}
expect "redis log"  {send "${ROOT_PATH}/redis.log\n"} 
expect "data directory" {send "${dir}\n"}
expect "executable path" {send "/usr/local/bin/redis-server\n"}
expect "Is this ok" {send "\n \r"}
expect "executable path" {send "exit\r"}
EOF
} && \
echo "Redis has config finish"
}

check_config (){
netstat -ntulp|grep ${REDISPORT}
if [ $? -eq 0 ];then
  echo "redis is setting successful"
  ${ROOT_PATH}/src/redis-cli shutdown  && \
  echo "redis stop successful"
else
  echo "redis is settting failed"
fi
if [ -z $ip ];then
  echo "you need get ip first"
  exit 2
fi  
}  

#${ROOT_PATH}/src/redis-cli shutdown  && \
#echo "redis stop successful" && \
setting_redis () {
cp ${configfile} ${configfile}.bak && \
sed -r -i "s;^(bind).*;\1 ${ip};" ${configfile} && \
sed -r -i "s;^(# )(requirepass).*;\2 ${pass};" ${configfile} && \
sed -r -i "s;^(# )(maxmemory-policy).*;\2 ${policy};"  ${configfile} && \
sed -r -i "s;^(appendonly).*;\1 yes;" ${configfile} && \
cp -f ${cmd}_6379   ${cmd} && \
echo "cp redis start shell successful" && \
CLIEXEC=/usr/local/bin/redis-cli
sed -i "43d" $cmd && \
sed -i "43i $CLIEXEC -h $ip -a $pass -p ${REDISPORT} shutdown"   $cmd && \
sed -i "3i IP=${ip} " $cmd   && \
sed -i "3i PASS=${pass}" $cmd  && \
$cmd start && \
netstat -tnulp|grep ${REDISPORT}
if [ $? -eq 0 ];then
  echo "redis id modify configfile successful,you can use it"
else
  echo "redis id modify configfile failed"
fi
#rm -rf ${path}
}

setup_dependrpm 
config_redis
check_config
setting_redis
echo "All setup steps have finished"
