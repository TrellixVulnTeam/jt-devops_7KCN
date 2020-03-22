!/bin/bash
IP=`ifconfig eth0|awk 'NR==2{print $2}'`
HTTP_CONF=/etc/httpd/conf/httpd.conf
HTTP_PORT=8092
PHP_CONF=/etc/php.ini
ZABBIX_RPM=/root/zabbix-4.0.0.tar.gz
ZABBIX_ROOT=/data/jtb/infra/zabbix
User=zabbix
ZABBIX_LOGDIR=/data/jtb/logs/zabbix
SERVER_CONF=/etc/zabbix/zabbix_server.conf
AGENT_CONF=/etc/zabbix/zabbix_agentd.conf
Bin=/data/jtb/bin

check_basic () {
   if [ -z ${IP} ];then
     echo "IP is null,please first get ip address"
   fi
   id ${User} > /dev/null 2>&1
   if [ $? -ne 0 ];then
     groupadd ${User}
     useradd -g ${User} -M -s /sbin/nologin ${User}
   fi
   if [ ! -e ${ZABBIX_LOGDIR} ];then
     mkdir ${ZABBIX_LOGDIR}
   fi
   chown ${User}:${User}  ${ZABBIX_LOGDIR}
}

install_http () {
   echo "Begin install http..."
   yum -y install httpd
   cp ${HTTP_CONF}  ${HTTP_CONF}.bak
   sed -r -i "s;^(Listen).*;\1 ${HTTP_PORT};" ${HTTP_CONF}  && \
   sed -r -i "s;^(#)(ServerName).*;\2 ${IP};" ${HTTP_CONF}  && \
   systemctl start httpd 
   systemctl enable httpd
   ss -tnulp|grep ${PORT}
   if [ $? -eq 0 ];then
     echo "Http has install finished"
   else
     echo "Http  install failed"
   fi
}

install_php () {
   yum -y install php php-mysql
   sed -r -i "s;^(max_execution_time =).*;\1 300;" ${PHP_CONF} && \
   sed -r -i "s;^(max_input_time =).*;\1 300;" ${PHP_CONF} && \
   sed -r -i "s;^(post_max_size =).*;\1 32M;" ${PHP_CONF}  && \
   sed -r -i "s,^(;)(date.timezone =),\2 Asia/Shanghai," ${PHP_CONF}  && \
   sed -r -i "s,^(;)(always_populate_raw_post_data =).*,\2 On," ${PHP_CONF}
}

install_zabbix () {
   yum -y install  gcc libxml2-devel net-snmp-devel  libcurl-devel libevent-devel  php-gd php-bcmath php-mbstring  php-xml  php-ldap
   tar -xf ${ZABBIX_RPM} -C /root
   cd ~/zabbix-4.0.0
   ./configure --prefix=${ZABBIX_ROOT} --sysconfdir=/etc/zabbix/ --enable-server --enable-agent --with-net-snmp --with-libcurl --with-mysql --with-libxml2
   make install
   if [ $? -eq 0 ];then
     echo "Zabbix has install finished"
   else
     echo "Zabbix  install failed"
   fi
   cp ${SERVER_CONF}  ${SERVER_CONF}.bak
   cp ${AGENT_CONF}   ${AGENT_CONF}.bak
echo "Begin sed zabbix server conf.."
   sed -r -i "s;^(LogFile=).*;\1${ZABBIX_LOGDIR}/zabbix_server.log;" ${SERVER_CONF}  && \
   sed -r -i "s;^(# )(PidFile=).*;\2${ZABBIX_ROOT}/zabbix_server.pid;" ${SERVER_CONF}  && \
   sed -r -i "s;^(# )(SocketDir=).*;\2${ZABBIX_ROOT};" ${SERVER_CONF}  && \
   sed -r -i "s;^(# )(DBPassword).*;\2=${User};" ${SERVER_CONF}  && \
   sed -r -i "s;^(# )(DBPort).*;\2=3306;"  ${SERVER_CONF}  && \
   sed -r -i "s;^(# )(AlertScriptsPath=).*;\2${Bin};" ${SERVER_CONF}
echo "Begin sed zabbix agent conf..."
   sed -r -i "s;^(# )(PidFile=).*;\2${ZABBIX_ROOT}/zabbix_agentd.pid;" ${AGENT_CONF} && \
   sed -r -i "s;^(LogFile=).*;\1${ZABBIX_LOGDIR}/zabbix_agentd.log;" ${AGENT_CONF} && \
   #sed -r -i "s;^(Server=).*;\1${IP};" ${AGENT_CONF}    && \
   sed -r -i "s;^(ServerActive=).*;\1$IP:10051;" ${AGENT_CONF}  && \
   echo "UnsafeUserParameters=1" >> ${AGENT_CONF}   && \
   echo "Include=/etc/zabbix/zabbix_agentd.conf.d/*.conf" >> ${AGENT_CONF}
}

config_mysql () {
  yum -y install expect
  expect <<EOF
  spawn mysql -uroot -p -e "set password=password('${USER}');"
  expect "Enter password" {send "\r \r"}
  expect "mysql"  {send "exit \r"}
EOF
  mysql -uroot -p${USER} -e "create database ${User} character set utf8"
  mysql -uroot -p${USER} -e "grant all on zabbix.* to ${User}@'localhost' identified by '${User}'"  && \
  cd ~/zabbix-4.0.0/database/mysql    && \
  mysql -u${User} -p${User} ${User}  < schema.sql  && \
  mysql -u${User} -p${User} ${User}  < images.sql  && \
  mysql -u${User} -p${User} ${User}  < data.sql    && \
  number=`mysql -u${User} -p${User} -e "show tables"|wc -l`
  if [ $number -gt 100 ];then
     echo "Config mysql successful"
  else
     echo "Config mysql failed"
  fi
}

config_zabbix () {
  cp ~/zabbix-4.0.0/misc/init.d/fedora/core/zabbix_* /etc/init.d
  chmod +x /etc/init.d/zabbix_*
  if [ ! -e /var/www/html/zabbix ];then
    mkdir /var/www/html/zabbix
  fi
  cp -r ~/zabbix-4.0.0/frontends/php/*  /var/www/html/zabbix/
  chown -R apache:apache  /var/www/html/zabbix
  chmod o+w /var/www/html/zabbix/conf
  sed -i "22c BASEDIR=${ZABBIX_ROOT}" /etc/init.d/zabbix_server
  sed -i "22c BASEDIR=${ZABBIX_ROOT}" /etc/init.d/zabbix_agentd
  sed -i "s;/tmp;${ZABBIX_ROOT};"  /etc/init.d/zabbix_server
  sed -i "s;/tmp;${ZABBIX_ROOT};"  /etc/init.d/zabbix_agentd
  chown -R ${User}:${User} ${ZABBIX_ROOT}
  /etc/init.d/zabbix_server start
  /etc/init.d/zabbix_agentd start
  if [ $? -eq 0 ];then 
   echo "Zabbix server start successful"
  else 
    echo "Zabbix server start failed"
  fi
}

check_basic
install_http  && \
install_php   && \
install_zabbix  && \
config_mysql   && \
config_zabbix
sed -r -i "s;^(ip=).*;\1$IP;" 20_install_zabbix_agent.sh
