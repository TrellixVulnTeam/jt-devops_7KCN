#!/bin/bash
CONFIG_FILE=/etc/my.cnf
TIME=`date +%Y%m%d`
LINE=`grep -n 'mysqld'  ${CONFIG_FILE} |awk -F: '{print $1}'` 
#Tips,before you execute this shell script,you need set root password first.
PASS="gzhXR6d@k*42FV"
REPLUSER=repluser
User=deployer
yum -y install expect

check_pass () {
 if [ -z ${PASS} ];then
   echo "Notice:You need set root password first,to variable $PASS"
   exit 3
 fi
}

set_master_mysql () {
cp -f ${CONFIG_FILE}  ${CONFIG_FILE}_${TIME}.bak && \
sed -i "${LINE}a binlog-format = "mixed"" ${CONFIG_FILE}  && \
sed -i "${LINE}a log-bin = mysql-master" ${CONFIG_FILE} && \
sed -i "${LINE}a server_id = 1"  ${CONFIG_FILE}  && \
/etc/init.d/mysqld restart
}

check_pass
set_master_mysql

expect <<EOF
  spawn mysql -uroot -p -e "set password=password('${PASS}');"
  expect "Enter password" {send "\r \r"}
  expect "mysql"  {send "exit \r"}
EOF

set_replication () {
 mysql -uroot -p${PASS} -e "grant replication slave on *.* to ${REPLUSER}@'%' identified by '${REPLUSER}';"
 mysql -uroot -p${PASS} -e "grant all on *.* to ${User}@'%' identified by '${PASS}';"
 mysql -uroot -p${PASS} -e "revoke drop on *.* from ${User}@'%';"
}
 
set_replication
sed -r -i "s;^(PASS=).*;\1${PASS};"  8_set_mysql_slave.sh
sed -r -i "s;^(pass=).*;\1${PASS};" 9_create_database.sh
sed -r -i "s;^(MYSQL_PASS=).*;\1${PASS};" 16_install_mycat.sh
