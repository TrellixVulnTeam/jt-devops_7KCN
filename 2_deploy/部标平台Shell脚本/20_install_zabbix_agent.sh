#!/bin/bash
setup_path=/data/jtb/infra/zabbix
zabbix_tar=/root/zabbix-4.0.0.tar.gz
cmd_path=/root/zabbix-4.0.0/misc/init.d/fedora/core
user=zabbix
config_file=${setup_path}/etc/zabbix_agentd.conf
log_dir=/data/jtb/logs/zabbix
#Tips:you need modify this ip,it is zabbix server address
ip=10.111.30.3
port=10051
echo "check depend enviroment..."
  if [ ! -e ${zabbix_tar} ];then
    echo "${zabbix_tar} is not exists.please docnload it"
  fi
  rpm -q gcc &> /dev/null
  if [ $? -ne 0 ];then
    yum -y install gcc  
  fi
  if [ ! -d  ${log_dir} ];then
    mkdir ${log_dir} && chown $user:$user ${log_dir}
  fi
echo "add user zabbix..."
  groupadd $user && useradd -g  $user $user -s /sbin/nologin
echo "begin tar  ${zabbix_tar}..."
  tar -xf ${zabbix_tar} -C /root && cd  ~/zabbix-4.0.0
echo "begin compile and setup and setting zabbix..."
  yum -y install pcre-devel 
  ./configure --prefix=${setup_path} --enable-agent && \
  make install && \
  cp ${cmd_path}/zabbix_agentd  /etc/init.d && \
  chown -R $user:$user ${setup_path}  && \
  chown -R $user:$user ${log_dir}  && \
  chmod +x /etc/init.d/zabbix_agentd  && \
  sed -i "22c BASEDIR=${setup_path}" /etc/init.d/zabbix_agentd && \
  sed -i "s;/tmp;${setup_path};"  /etc/init.d/zabbix_agentd
  cp ${config_file}{,.bak}   && \
  sed -r -i "s;^(LogFile=).*;\1${log_dir}/zabbix_agentd.log;" ${config_file} && \
  sed -r -i "s;^(Server=).*;\1$ip;" ${config_file}    && \
  sed -r -i "s;^(ServerActive=).*;\1$ip:$port;" ${config_file}  && \
  sed -r -i "s;^(# )(PidFile=).*;\2${setup_path}/zabbix_agentd.pid;"  ${config_file}
  echo "UnsafeUserParameters=1" >> ${config_file}   && \
  echo "Include=${setup_path}/etc/zabbix_agentd.conf.d/*.conf" >> ${config_file}
  /etc/init.d/zabbix_agentd start && \
  netstat -anp|grep 10050
  if [ $? -eq 0 ];then
    echo "Zabbix_agentd installed Successful"
  else 
    echo "Zabbix_agentd  installed Failed"
  fi
  ln -s /data/jtb/infra/zabbix/etc/zabbix_agentd.conf  /etc/zabbix_agentd.conf
