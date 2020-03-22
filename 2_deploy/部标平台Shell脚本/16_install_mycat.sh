#!/bin/bash
MYCAT_RPM=/root/Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz
MYCAT_ROOT=/data/jtb/infra
SERVER_XML=/root/server.xml
RULE_XML=/root/rule.xml
SCHEMA_XML=/root/schema.xml
ROUTER_XML=/root/router.xml
ORI=123456
MYCAT_PASS=8hA5fFniE0P4MN
MYSQL_PASS=gzhXR6d@k*42FV
SIP=0.0.0.0
DIP=`ifconfig eth0|awk 'NR==2{print $2}'`



check_ip () {
  if [ -z ${DIP} ];then
    echo "Please check network card name,make sure it is eth0 or not"
    exit 1
  fi 
}


setup_mycat () {
 echo "Begin set Mycat server..."   && \
 tar -xf ${MYCAT_RPM} -C ${MYCAT_ROOT}  && \
 cp -f ${RULE_XML} ${MYCAT_ROOT}/mycat/conf  && \
 cp -f ${ROUTER_XML} ${MYCAT_ROOT}/mycat/conf   && \
 cp -f ${SERVER_XML} ${MYCAT_ROOT}/mycat/conf   && \
 cp -f ${SCHEMA_XML} ${MYCAT_ROOT}/mycat/conf   && \
 sed -i "s;${ORI};${MYCAT_PASS};" ${MYCAT_ROOT}/mycat/conf/server.xml  && \
 sed -i "s;${ORI};${MYSQL_PASS};" ${MYCAT_ROOT}/mycat/conf/schema.xml  && \
 sed -i "s;${SIP};${DIP};"  ${MYCAT_ROOT}/mycat/conf/schema.xml  && \
 echo "Mycat config file has set successful"  && \
 echo "Begin start Mycat server..."
 ${MYCAT_ROOT}/mycat/bin/mycat start
 sleep 3
 ss -tnulp|grep 8066
 retval=$?
 if [ ${retval} -ne 0 ];then 
   echo "Mycat server start failed,please check configfile"
 fi
}


check_ip && \
setup_mycat
