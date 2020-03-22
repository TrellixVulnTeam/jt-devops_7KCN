#!/bin/bash
CONFIG_FILE=/etc/my.cnf
TIME=`date +%Y%m%d`
LINE=`grep -n 'mysqld'  ${CONFIG_FILE} |awk -F: '{print $1}'` 
PASS="gzhXR6d@k*42FV"
REPLUSER=repluser
User=deployer
###Notice:You must know,this is set mysql_slave node,so you should get mysql master ip first,then set it to variable $IP
IP="10.111.30.10"
yum -y install expect

check_ip () {
   ping -c 3 ${IP} > /dev/null 2>&1
   retval=$?
   if [ ${retval} -ne 0 ];then
     echo "Tips:you must first to get ip,then you can go execute this shell script"
     exit 2
   fi
}

check_pass () {
 if [ -z ${PASS} ];then
   echo "Notice:You need set root password first,to variable PASS"
   exit 3
 fi
}


set_slave_mysql () {
cp -f ${CONFIG_FILE}  ${CONFIG_FILE}_${TIME}.bak && \
sed -i "${LINE}a server_id = 2"  ${CONFIG_FILE}  && \
/etc/init.d/mysqld restart
}

check_ip && \
check_pass && \
set_slave_mysql

expect <<EOF
  spawn mysql -uroot -p -e "set password=password('${PASS}');"
  expect "Enter password" {send "\r \r"}
  expect "mysql"  {send "exit \r"}
EOF


set_replication () {
 mysql -uroot -p${PASS} -e "grant all on *.* to ${User}@'%' identified by '${PASS}';"
 mysql -uroot -p${PASS} -e "revoke drop on *.* from ${User}@'%';"
 file=`mysql -uroot -h${IP} -p${PASS} -e "show master status\G;"|awk -F '[: ]+' '/File/{print $NF}'` && \
 pos=`mysql -uroot -h${IP} -p${PASS} -e "show master status\G;"|awk -F '[: ]+' '/Position/{print $NF}'` && \
 mysql -uroot -p${PASS} -e "change master to master_host='"${IP}"',master_user='"${REPLUSER}"',master_password='"${REPLUSER}"',master_log_file='"${file}"',master_log_pos=${pos};" && \
 mysql -uroot -p${PASS} -e "start slave;" && \
 Result=`mysql -uroot -p${PASS} -e "show slave status\G;"|egrep -w "Slave_IO_Running|Slave_SQL_Running"|awk -F: '{print $NF}'`
 for result in  ${Result};do 
   if [[ ${result} != "Yes" ]];then
     echo "Slave is not replcat from Master Mysql"
     exit 4
   else
     echo "Slave is replcat from Master Mysql"
   fi
 done 
}

set_replication
